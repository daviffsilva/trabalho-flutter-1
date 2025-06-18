package com.entregas.rastreamento.service;

import com.entregas.rastreamento.dto.LocalizacaoResponse;
import com.entregas.rastreamento.dto.LocalizacaoUpdateRequest;
import com.entregas.rastreamento.exception.LocationNotFoundException;
import com.entregas.rastreamento.model.Localizacao;
import com.entregas.rastreamento.repository.LocalizacaoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class LocalizacaoService {

    @Autowired
    private LocalizacaoRepository localizacaoRepository;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    public LocalizacaoResponse updateLocation(LocalizacaoUpdateRequest request) {
        Localizacao localizacao = new Localizacao();
        localizacao.setDriverId(request.getDriverId());
        localizacao.setLatitude(request.getLatitude());
        localizacao.setLongitude(request.getLongitude());
        localizacao.setAltitude(request.getAltitude());
        localizacao.setSpeed(request.getSpeed());
        localizacao.setHeading(request.getHeading());
        localizacao.setAccuracy(request.getAccuracy());
        localizacao.setPedidoId(request.getPedidoId());
        localizacao.setTimestamp(LocalDateTime.now());
        localizacao.setIsActive(true);

        Localizacao savedLocalizacao = localizacaoRepository.save(localizacao);
        LocalizacaoResponse response = convertToResponse(savedLocalizacao);

        broadcastLocationUpdate(response);
        return response;
    }

    public LocalizacaoResponse getLatestLocationByDriverId(Long driverId) {
        Optional<Localizacao> localizacao = localizacaoRepository.findLatestLocationByDriverId(driverId);
        if (localizacao.isPresent()) {
            return convertToResponse(localizacao.get());
        }
        throw new LocationNotFoundException("No location found for driver ID: " + driverId);
    }

    public LocalizacaoResponse getLatestLocationByPedidoId(Long pedidoId) {
        Optional<Localizacao> localizacao = localizacaoRepository.findLatestLocationByPedidoId(pedidoId);
        if (localizacao.isPresent()) {
            return convertToResponse(localizacao.get());
        }
        throw new LocationNotFoundException("No location found for pedido ID: " + pedidoId);
    }

    public List<LocalizacaoResponse> getLocationsByDriverId(Long driverId) {
        List<Localizacao> localizacoes = localizacaoRepository.findByDriverIdOrderByTimestampDesc(driverId);
        return localizacoes.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<LocalizacaoResponse> getLocationsByPedidoId(Long pedidoId) {
        List<Localizacao> localizacoes = localizacaoRepository.findByPedidoIdOrderByTimestampDesc(pedidoId);
        return localizacoes.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<LocalizacaoResponse> getLocationsByDriverIdAndTimeRange(Long driverId, LocalDateTime startTime) {
        List<Localizacao> localizacoes = localizacaoRepository.findLocationsByDriverIdAndTimeRange(driverId, startTime);
        return localizacoes.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<LocalizacaoResponse> getLocationsByPedidoIdAndTimeRange(Long pedidoId, LocalDateTime startTime) {
        List<Localizacao> localizacoes = localizacaoRepository.findLocationsByPedidoIdAndTimeRange(pedidoId, startTime);
        return localizacoes.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<LocalizacaoResponse> getActiveLocationsSince(LocalDateTime startTime) {
        List<Localizacao> localizacoes = localizacaoRepository.findActiveLocationsSince(startTime);
        return localizacoes.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public List<LocalizacaoResponse> getLocationsByDriverAndPedido(Long driverId, Long pedidoId) {
        List<Localizacao> localizacoes = localizacaoRepository.findLocationsByDriverAndPedido(driverId, pedidoId);
        return localizacoes.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public void deactivateLocation(Long id) {
        Localizacao localizacao = localizacaoRepository.findById(id)
                .orElseThrow(() -> new LocationNotFoundException("Location not found with ID: " + id));
        localizacao.setIsActive(false);
        localizacaoRepository.save(localizacao);
    }

    private LocalizacaoResponse convertToResponse(Localizacao localizacao) {
        LocalizacaoResponse response = new LocalizacaoResponse();
        response.setId(localizacao.getId());
        response.setDriverId(localizacao.getDriverId());
        response.setLatitude(localizacao.getLatitude());
        response.setLongitude(localizacao.getLongitude());
        response.setAltitude(localizacao.getAltitude());
        response.setSpeed(localizacao.getSpeed());
        response.setHeading(localizacao.getHeading());
        response.setAccuracy(localizacao.getAccuracy());
        response.setTimestamp(localizacao.getTimestamp());
        response.setPedidoId(localizacao.getPedidoId());
        response.setIsActive(localizacao.getIsActive());
        response.setCreatedAt(localizacao.getCreatedAt());
        response.setUpdatedAt(localizacao.getUpdatedAt());
        return response;
    }

    private void broadcastLocationUpdate(LocalizacaoResponse response) {
        System.out.println("Broadcastando localização: " + response);
        messagingTemplate.convertAndSend("/topic/location-updates", response);
        if (response.getDriverId() != null) {
            messagingTemplate.convertAndSend("/topic/driver/" + response.getDriverId() + "/location", response);
        }
        if (response.getPedidoId() != null) {
            messagingTemplate.convertAndSend("/topic/pedido/" + response.getPedidoId() + "/location", response);
        }
    }
} 