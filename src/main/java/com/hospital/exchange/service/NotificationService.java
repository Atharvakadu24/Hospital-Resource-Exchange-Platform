package com.hospital.exchange.service;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class NotificationService {

    private final SimpMessagingTemplate messagingTemplate;

    public NotificationService(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    public void notifyResourceUpdate(Long resourceId, String status) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "RESOURCE_UPDATE");
        payload.put("resourceId", resourceId);
        payload.put("status", status);
        messagingTemplate.convertAndSend("/topic/network-updates", (Object) payload);
    }

    public void notifyNewRequest(Long requestId, String hospitalName, String resourceType) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "NEW_REQUEST");
        payload.put("requestId", requestId);
        payload.put("hospital", hospitalName);
        payload.put("resourceType", resourceType);
        messagingTemplate.convertAndSend("/topic/network-updates", (Object) payload);
    }

    public void notifyAllocationComplete(Long bookingId, String hospitalName, String resourceName) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("type", "ALLOCATION_COMPLETE");
        payload.put("bookingId", bookingId);
        payload.put("hospital", hospitalName);
        payload.put("resourceName", resourceName);
        messagingTemplate.convertAndSend("/topic/network-updates", (Object) payload);
    }
}
