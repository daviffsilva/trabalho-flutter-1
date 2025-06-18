package com.entregas.pedidos.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "Objeto de resposta de rota otimizada")
public class RouteResponse {

    @Schema(description = "Distância total em km", example = "15.5")
    private Double distance;

    @Schema(description = "Duração estimada em minutos", example = "45")
    private Integer duration;

    @Schema(description = "Coordenadas da rota")
    private List<Coordinate> coordinates;

    @Schema(description = "Instruções de navegação")
    private List<String> instructions;

    public RouteResponse() {}

    public RouteResponse(Double distance, Integer duration, List<Coordinate> coordinates, List<String> instructions) {
        this.distance = distance;
        this.duration = duration;
        this.coordinates = coordinates;
        this.instructions = instructions;
    }

    public Double getDistance() {
        return distance;
    }

    public void setDistance(Double distance) {
        this.distance = distance;
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    public List<Coordinate> getCoordinates() {
        return coordinates;
    }

    public void setCoordinates(List<Coordinate> coordinates) {
        this.coordinates = coordinates;
    }

    public List<String> getInstructions() {
        return instructions;
    }

    public void setInstructions(List<String> instructions) {
        this.instructions = instructions;
    }

    @Schema(description = "Coordenada geográfica")
    public static class Coordinate {
        @Schema(description = "Latitude", example = "-23.5505")
        private Double latitude;

        @Schema(description = "Longitude", example = "-46.6333")
        private Double longitude;

        public Coordinate() {}

        public Coordinate(Double latitude, Double longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }

        public Double getLatitude() {
            return latitude;
        }

        public void setLatitude(Double latitude) {
            this.latitude = latitude;
        }

        public Double getLongitude() {
            return longitude;
        }

        public void setLongitude(Double longitude) {
            this.longitude = longitude;
        }
    }
} 