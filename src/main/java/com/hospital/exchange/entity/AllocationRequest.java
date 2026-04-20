package com.hospital.exchange.entity;

import com.hospital.exchange.model.ResourceType;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "allocation_requests")
public class AllocationRequest implements Comparable<AllocationRequest> {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "requester_hospital_id", nullable = false)
    private Hospital requesterHospital;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ResourceType resourceType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RequestPriority priority;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RequestStatus status;

    @Column(nullable = false)
    private LocalDateTime requestedAt;

    @Column(nullable = false)
    private LocalDateTime startTime;

    @Column(nullable = false)
    private LocalDateTime endTime;

    public AllocationRequest() {}

    public AllocationRequest(Long id, Hospital requesterHospital, ResourceType resourceType, 
                            RequestPriority priority, RequestStatus status, 
                            LocalDateTime requestedAt, LocalDateTime startTime, LocalDateTime endTime) {
        this.id = id;
        this.requesterHospital = requesterHospital;
        this.resourceType = resourceType;
        this.priority = priority;
        this.status = status;
        this.requestedAt = requestedAt;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    public enum RequestPriority {
        EMERGENCY(3),
        HIGH(2),
        NORMAL(1);

        private final int value;
        RequestPriority(int value) { this.value = value; }
        public int getValue() { return value; }
    }

    public enum RequestStatus {
        PENDING,
        WAITING,
        APPROVED,
        DENIED,
        CANCELLED,
        REJECTED_DEADLOCK
    }

    // Builder-like approach
    public static AllocationRequestBuilder builder() {
        return new AllocationRequestBuilder();
    }

    public static class AllocationRequestBuilder {
        private Long id;
        private Hospital requesterHospital;
        private ResourceType resourceType;
        private RequestPriority priority;
        private RequestStatus status;
        private LocalDateTime requestedAt;
        private LocalDateTime startTime;
        private LocalDateTime endTime;

        public AllocationRequestBuilder id(Long id) { this.id = id; return this; }
        public AllocationRequestBuilder requesterHospital(Hospital requesterHospital) { this.requesterHospital = requesterHospital; return this; }
        public AllocationRequestBuilder resourceType(ResourceType resourceType) { this.resourceType = resourceType; return this; }
        public AllocationRequestBuilder priority(RequestPriority priority) { this.priority = priority; return this; }
        public AllocationRequestBuilder status(RequestStatus status) { this.status = status; return this; }
        public AllocationRequestBuilder requestedAt(LocalDateTime requestedAt) { this.requestedAt = requestedAt; return this; }
        public AllocationRequestBuilder startTime(LocalDateTime startTime) { this.startTime = startTime; return this; }
        public AllocationRequestBuilder endTime(LocalDateTime endTime) { this.endTime = endTime; return this; }
        public AllocationRequest build() {
            return new AllocationRequest(id, requesterHospital, resourceType, priority, status, requestedAt, startTime, endTime);
        }
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Hospital getRequesterHospital() { return requesterHospital; }
    public void setRequesterHospital(Hospital requesterHospital) { this.requesterHospital = requesterHospital; }
    public ResourceType getResourceType() { return resourceType; }
    public void setResourceType(ResourceType resourceType) { this.resourceType = resourceType; }
    public RequestPriority getPriority() { return priority; }
    public void setPriority(RequestPriority priority) { this.priority = priority; }
    public RequestStatus getStatus() { return status; }
    public void setStatus(RequestStatus status) { this.status = status; }
    public LocalDateTime getRequestedAt() { return requestedAt; }
    public void setRequestedAt(LocalDateTime requestedAt) { this.requestedAt = requestedAt; }
    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }
    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }

    @Override
    public int compareTo(AllocationRequest other) {
        int priorityCompare = Integer.compare(other.priority.getValue(), this.priority.getValue());
        if (priorityCompare != 0) {
            return priorityCompare;
        }
        return this.requestedAt.compareTo(other.requestedAt);
    }
}
