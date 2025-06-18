package com.entregas.pedidos.service;

import com.entregas.pedidos.dto.RouteResponse;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;

@Service
public class RouteService {

    private final RestTemplate restTemplate = new RestTemplate();
    private static final String OSRM_BASE_URL = "http://router.project-osrm.org/route/v1/driving/";

    public RouteResponse calculateRoute(Double originLat, Double originLng, 
                                      Double destLat, Double destLng) {
        try {
            String url = String.format("%s%f,%f;%f,%f?overview=full&steps=true",
                    OSRM_BASE_URL, originLng, originLat, destLng, destLat);

            OSRMResponse osrmResponse = restTemplate.getForObject(url, OSRMResponse.class);

            if (osrmResponse != null && !osrmResponse.routes.isEmpty()) {
                OSRMRoute route = osrmResponse.routes.get(0);
                
                List<RouteResponse.Coordinate> coordinates = new ArrayList<>();
                if (route.geometry != null && route.geometry.coordinates != null) {
                    for (List<Double> coord : route.geometry.coordinates) {
                        coordinates.add(new RouteResponse.Coordinate(coord.get(1), coord.get(0)));
                    }
                }

                List<String> instructions = new ArrayList<>();
                if (route.legs != null && !route.legs.isEmpty()) {
                    OSRMLeg leg = route.legs.get(0);
                    if (leg.steps != null) {
                        for (OSRMStep step : leg.steps) {
                            if (step.maneuver != null && step.maneuver.instruction != null) {
                                instructions.add(step.maneuver.instruction);
                            }
                        }
                    }
                }

                return new RouteResponse(
                        route.distance / 1000.0, // Convert to km
                        (int) (route.duration / 60.0), // Convert to minutes
                        coordinates,
                        instructions
                );
            }
        } catch (Exception e) {
            // Fallback to simple calculation if external API fails
            return calculateSimpleRoute(originLat, originLng, destLat, destLng);
        }

        return calculateSimpleRoute(originLat, originLng, destLat, destLng);
    }

    private RouteResponse calculateSimpleRoute(Double originLat, Double originLng, 
                                             Double destLat, Double destLng) {
        // Simple distance calculation using Haversine formula
        double distance = calculateHaversineDistance(originLat, originLng, destLat, destLng);
        int duration = (int) (distance * 2.5); // Rough estimate: 2.5 minutes per km

        List<RouteResponse.Coordinate> coordinates = new ArrayList<>();
        coordinates.add(new RouteResponse.Coordinate(originLat, originLng));
        coordinates.add(new RouteResponse.Coordinate(destLat, destLng));

        List<String> instructions = new ArrayList<>();
        instructions.add("Dirija-se ao destino");

        return new RouteResponse(distance, duration, coordinates, instructions);
    }

    private double calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Earth's radius in kilometers

        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    // OSRM API Response classes
    private static class OSRMResponse {
        public List<OSRMRoute> routes;
    }

    private static class OSRMRoute {
        public double distance;
        public double duration;
        public OSRMGeometry geometry;
        public List<OSRMLeg> legs;
    }

    private static class OSRMGeometry {
        public List<List<Double>> coordinates;
    }

    private static class OSRMLeg {
        public List<OSRMStep> steps;
    }

    private static class OSRMStep {
        public OSRMManeuver maneuver;
    }

    private static class OSRMManeuver {
        public String instruction;
    }
} 