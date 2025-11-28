import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as location;

class LiveTrackingController extends GetxController {
  GoogleMapController? mapController;
  final flutterMap.MapController osmMapController = flutterMap.MapController();

  @override
  void onInit() {
    // TODO: implement onInit
    addMarkerSetup();
    getArgument();
    super.onInit();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<UserModel> driverUserModel = UserModel().obs;
  RxBool isLoading = true.obs;

  Rx<location.LatLng> source = location.LatLng(21.1702, 72.8311).obs; // Start (e.g., Surat)
  Rx<location.LatLng> current = location.LatLng(21.1800, 72.8400).obs; // Moving marker
  Rx<location.LatLng> destination = location.LatLng(21.2000, 72.8600).obs; // Destination

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
      FireStoreUtils.fireStore
          .collection(CollectionName.restaurantOrders)
          .doc(orderModel.value.id)
          .snapshots()
          .listen((event) {
        if (event.data() != null) {
          OrderModel orderModelStream = OrderModel.fromJson(event.data()!);
          orderModel.value = orderModelStream;
          FireStoreUtils.fireStore
              .collection(CollectionName.users)
              .doc(orderModel.value.driverID)
              .snapshots()
              .listen((event) {
            if (event.data() != null) {
              driverUserModel.value = UserModel.fromJson(event.data()!);
              if (Constant.selectedMapType != 'osm') {
                if (orderModel.value.status == Constant.orderShipped) {
                  getPolyline(
                      sourceLatitude: driverUserModel.value.location!.latitude,
                      sourceLongitude: driverUserModel.value.location!.longitude,
                      destinationLatitude: orderModel.value.vendor!.latitude,
                      destinationLongitude: orderModel.value.vendor!.longitude);
                } else if (orderModel.value.status == Constant.orderInTransit) {
                  getPolyline(
                      sourceLatitude: driverUserModel.value.location!.latitude,
                      sourceLongitude: driverUserModel.value.location!.longitude,
                      destinationLatitude: orderModel.value.address!.location!.latitude,
                      destinationLongitude: orderModel.value.address!.location!.longitude);
                } else {
                  getPolyline(
                      sourceLatitude: orderModel.value.address!.location!.latitude,
                      sourceLongitude: orderModel.value.address!.location!.longitude,
                      destinationLatitude: orderModel.value.vendor!.latitude,
                      destinationLongitude: orderModel.value.vendor!.longitude);
                }
              } else {
                if (orderModel.value.status == Constant.orderShipped) {
                  current.value = location.LatLng(driverUserModel.value.location!.latitude ?? 0.0,
                      driverUserModel.value.location!.longitude ?? 0.0);
                  source.value = location.LatLng(orderModel.value.vendor!.latitude ?? 0.0,
                      orderModel.value.vendor!.longitude ?? 0.0);
                  destination.value = location.LatLng(
                      orderModel.value.address!.location!.latitude ?? 0.0,
                      orderModel.value.address!.location!.longitude ?? 0.0);
                  fetchRoute(current.value, source.value);
                  animateToSource();
                } else if (orderModel.value.status == Constant.orderInTransit) {
                  current.value = location.LatLng(driverUserModel.value.location!.latitude ?? 0.0,
                      driverUserModel.value.location!.longitude ?? 0.0);
                  source.value = location.LatLng(orderModel.value.vendor!.latitude ?? 0.0,
                      orderModel.value.vendor!.longitude ?? 0.0);
                  destination.value = location.LatLng(
                      orderModel.value.address!.location!.latitude ?? 0.0,
                      orderModel.value.address!.location!.longitude ?? 0.0);
                  fetchRoute(current.value, destination.value);
                  animateToSource();
                } else {
                  current.value = location.LatLng(driverUserModel.value.location!.latitude ?? 0.0,
                      driverUserModel.value.location!.longitude ?? 0.0);
                  source.value = location.LatLng(orderModel.value.vendor!.latitude ?? 0.0,
                      orderModel.value.vendor!.longitude ?? 0.0);
                  destination.value = location.LatLng(
                      orderModel.value.address!.location!.latitude ?? 0.0,
                      orderModel.value.address!.location!.longitude ?? 0.0);
                  fetchRoute(current.value, source.value);
                  animateToSource();
                }
              }
            }
          });

          if (orderModel.value.status == Constant.orderCompleted) {
            Get.back();
          }
        }
      });
    }

    isLoading.value = false;

    update();
  }

  void animateToSource() {
    osmMapController.move(
        location.LatLng(driverUserModel.value.location!.latitude ?? 0.0,
            driverUserModel.value.location!.longitude ?? 0.0),
        16);
  }

  RxList<location.LatLng> routePoints = <location.LatLng>[].obs;

  Future<void> fetchRoute(location.LatLng source, location.LatLng destination) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${source.longitude},${source.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final geometry = decoded['routes'][0]['geometry']['coordinates'];

      routePoints.clear();
      for (var coord in geometry) {
        final lon = coord[0];
        final lat = coord[1];
        routePoints.add(location.LatLng(lat, lon));
      }
    } else {
      print("Failed to get route: ${response.body}");
    }
  }

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;

  void getPolyline(
      {required double? sourceLatitude,
      required double? sourceLongitude,
      required double? destinationLatitude,
      required double? destinationLongitude}) async {
    if (sourceLatitude != null &&
        sourceLongitude != null &&
        destinationLatitude != null &&
        destinationLongitude != null) {
      List<LatLng> polylineCoordinates = [];
      PolylineRequest polylineRequest = PolylineRequest(
        origin: PointLatLng(sourceLatitude, sourceLongitude),
        destination: PointLatLng(destinationLatitude, destinationLongitude),
        mode: TravelMode.driving,
      );

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: polylineRequest,
        // googleApiKey: Constant.mapAPIKey,
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        print(result.errorMessage.toString());
      }
      if (orderModel.value.status == Constant.orderShipped) {
        addMarker(
            latitude: driverUserModel.value.location!.latitude,
            longitude: driverUserModel.value.location!.longitude,
            id: "Driver",
            descriptor: driverIcon!,
            rotation: double.parse(driverUserModel.value.rotation.toString()));
        addMarker(
          latitude: orderModel.value.vendor!.latitude,
          longitude: orderModel.value.vendor!.longitude,
          id: "Departure",
          descriptor: departureIcon!,
          rotation: 0.0,
        );
      } else if (orderModel.value.status == Constant.orderInTransit) {
        addMarker(
            latitude: driverUserModel.value.location!.latitude,
            longitude: driverUserModel.value.location!.longitude,
            id: "Driver",
            descriptor: driverIcon!,
            rotation: double.parse(driverUserModel.value.rotation.toString()));
        addMarker(
            latitude: orderModel.value.address!.location!.latitude,
            longitude: orderModel.value.address!.location!.longitude,
            id: "Destination",
            descriptor: destinationIcon!,
            rotation: 0.0);
      } else {
        addMarker(
            latitude: orderModel.value.vendor!.latitude,
            longitude: orderModel.value.vendor!.longitude,
            id: "Departure",
            descriptor: departureIcon!,
            rotation: 0.0);
        addMarker(
            latitude: orderModel.value.address!.location!.latitude,
            longitude: orderModel.value.address!.location!.longitude,
            id: "Destination",
            descriptor: destinationIcon!,
            rotation: 0.0);
      }

      _addPolyLine(polylineCoordinates);
    }
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  addMarker(
      {required double? latitude,
      required double? longitude,
      required String id,
      required BitmapDescriptor descriptor,
      required double? rotation}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
        markerId: markerId,
        icon: descriptor,
        position: LatLng(latitude ?? 0.0, longitude ?? 0.0),
        rotation: rotation ?? 0.0);
    markers[markerId] = marker;
  }

  addMarkerSetup() async {
    if (Constant.selectedMapType != 'osm') {
      final Uint8List departure =
          await Constant().getBytesFromAsset('assets/images/pickup.png', 100);
      final Uint8List destination =
          await Constant().getBytesFromAsset('assets/images/dropoff.png', 100);
      final Uint8List driver =
          await Constant().getBytesFromAsset('assets/images/food_delivery.png', 100);
      departureIcon = BitmapDescriptor.fromBytes(departure);
      destinationIcon = BitmapDescriptor.fromBytes(destination);
      driverIcon = BitmapDescriptor.fromBytes(driver, size: Size(100.0, 100.0));
    } else {
      // departureOsmIcon =
      //     Image.asset("assets/images/pickup.png", width: 30, height: 30); //OSM
      // destinationOsmIcon =
      //     Image.asset("assets/images/dropoff.png", width: 30, height: 30); //OSM
      // driverOsmIcon = Image.asset("assets/images/food_delivery.png",
      //     width: 30, height: 30); //OSM
    }
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey);

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      consumeTapEvents: true,
      startCap: Cap.roundCap,
      width: 6,
    );
    polyLines[id] = polyline;
    updateCameraLocation(polylineCoordinates.first, polylineCoordinates.last, mapController);
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController? mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

//OSM
// late MapController mapOsmController;
// Rx<RoadInfo> roadInfo = RoadInfo().obs;
// Map<String, GeoPoint> osmMarkers = <String, GeoPoint>{};
// Image? departureOsmIcon; //OSM
// Image? destinationOsmIcon; //OSM
// Image? driverOsmIcon;
//
// Future<void> updateOSMCameraLocation(
//     {required GeoPoint source, required GeoPoint destination}) async {
//   BoundingBox bounds;
//
//   if (source.latitude > destination.latitude &&
//       source.longitude > destination.longitude) {
//     bounds = BoundingBox(
//       north: source.latitude,
//       south: destination.latitude,
//       east: source.longitude,
//       west: destination.longitude,
//     );
//   } else if (source.longitude > destination.longitude) {
//     bounds = BoundingBox(
//       north: destination.latitude,
//       south: source.latitude,
//       east: source.longitude,
//       west: destination.longitude,
//     );
//   } else if (source.latitude > destination.latitude) {
//     bounds = BoundingBox(
//       north: source.latitude,
//       south: destination.latitude,
//       east: destination.longitude,
//       west: source.longitude,
//     );
//   } else {
//     bounds = BoundingBox(
//       north: destination.latitude,
//       south: source.latitude,
//       east: destination.longitude,
//       west: source.longitude,
//     );
//   }
//
//   await mapOsmController.zoomToBoundingBox(bounds, paddinInPixel: 100);
// }
//
// setOsmMarker(
//     {required GeoPoint departure, required GeoPoint destination}) async {
//   WidgetsBinding.instance.addPostFrameCallback((_) async {
//     if (osmMarkers.containsKey('Driver')) {
//       await mapOsmController.removeMarker(osmMarkers['Driver']!);
//     }
//
//     if (osmMarkers.containsKey('Source')) {
//       await mapOsmController.removeMarker(osmMarkers['Source']!);
//     }
//
//     if (osmMarkers.containsKey('Destination')) {
//       await mapOsmController.removeMarker(osmMarkers['Destination']!);
//     }
//
//     await mapOsmController
//         .addMarker(
//             GeoPoint(
//                 latitude: driverUserModel.value.location!.latitude!,
//                 longitude: driverUserModel.value.location!.longitude!),
//             markerIcon: MarkerIcon(iconWidget: driverOsmIcon),
//             angle: pi / 3,
//             iconAnchor: IconAnchor(
//               anchor: Anchor.top,
//             ))
//         .then((v) {
//       osmMarkers['Driver'] = GeoPoint(
//           latitude: driverUserModel.value.location!.latitude!,
//           longitude: driverUserModel.value.location!.longitude!);
//     });
//
//     await mapOsmController
//         .addMarker(departure,
//             markerIcon: MarkerIcon(iconWidget: departureOsmIcon),
//             angle: pi / 3,
//             iconAnchor: IconAnchor(
//               anchor: Anchor.top,
//             ))
//         .then((v) {
//       osmMarkers['Source'] = departure;
//     });
//
//     await mapOsmController
//         .addMarker(destination,
//             markerIcon: MarkerIcon(iconWidget: destinationOsmIcon),
//             angle: pi / 3,
//             iconAnchor: IconAnchor(
//               anchor: Anchor.top,
//             ))
//         .then((v) {
//       osmMarkers['Destination'] = destination;
//     });
//   });
//   getOSMPolyline();
// }
//
// void getOSMPolyline() async {
//   try {
//     GeoPoint destinationLocation;
//     if (orderModel.value.status == Constant.orderShipped) {
//       destinationLocation = GeoPoint(
//           latitude: orderModel.value.vendor!.latitude ?? 0,
//           longitude: orderModel.value.vendor!.longitude ?? 0);
//     } else {
//       destinationLocation = GeoPoint(
//           latitude: orderModel.value.address!.location!.latitude ?? 0,
//           longitude: orderModel.value.address!.location!.longitude ?? 0);
//     }
//
//     await mapOsmController.removeLastRoad();
//     roadInfo.value = await mapOsmController.drawRoad(
//       GeoPoint(
//           latitude: driverUserModel.value.location!.latitude!,
//           longitude: driverUserModel.value.location!.longitude!),
//       destinationLocation,
//       roadType: RoadType.car,
//       roadOption: RoadOption(
//         roadWidth: Platform.isIOS ? 50 : 10,
//         roadColor: Colors.blue,
//         roadBorderWidth:
//             Platform.isIOS ? 15 : 10, // Set the road border width (outline)
//         roadBorderColor: Colors.black, // Border color
//         zoomInto: true,
//       ),
//     );
//     mapOsmController.goToLocation(
//       GeoPoint(
//           latitude: driverUserModel.value.location!.latitude!,
//           longitude: driverUserModel.value.location!.longitude!),
//     );
//   } catch (e) {
//     print('Error: $e');
//   }
// }
}
