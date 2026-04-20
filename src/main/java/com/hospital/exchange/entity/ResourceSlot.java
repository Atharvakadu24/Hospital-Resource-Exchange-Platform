package com.hospital.exchange.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "resource_slots")
public class ResourceSlot {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "resource_id", nullable = false)
    private Resource resource;

    @Column(nullable = false)
    private LocalDateTime startTime;

    @Column(nullable = false)
    private LocalDateTime endTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SlotStatus bookingStatus;

    public ResourceSlot() {}

    public ResourceSlot(Long id, Resource resource, LocalDateTime startTime, LocalDateTime endTime, SlotStatus bookingStatus) {
        this.id = id;
        this.resource = resource;
        this.startTime = startTime;
        this.endTime = endTime;
        this.bookingStatus = bookingStatus;
    }

    public enum SlotStatus {
        OPEN,
        BOOKED,
        BLOCKED
    }

    // Builder
    public static ResourceSlotBuilder builder() {
        return new ResourceSlotBuilder();
    }

    public static class ResourceSlotBuilder {
        private Long id;
        private Resource resource;
        private LocalDateTime startTime;
        private LocalDateTime endTime;
        private SlotStatus bookingStatus;

        public ResourceSlotBuilder id(Long id) { this.id = id; return this; }
        public ResourceSlotBuilder resource(Resource resource) { this.resource = resource; return this; }
        public ResourceSlotBuilder startTime(LocalDateTime startTime) { this.startTime = startTime; return this; }
        public ResourceSlotBuilder endTime(LocalDateTime endTime) { this.endTime = endTime; return this; }
        public ResourceSlotBuilder bookingStatus(SlotStatus bookingStatus) { this.bookingStatus = bookingStatus; return this; }
        public ResourceSlot build() {
            return new ResourceSlot(id, resource, startTime, endTime, bookingStatus);
        }
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Resource getResource() { return resource; }
    public void setResource(Resource resource) { this.resource = resource; }
    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }
    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }
    public SlotStatus getBookingStatus() { return bookingStatus; }
    public void setBookingStatus(SlotStatus bookingStatus) { this.bookingStatus = bookingStatus; }
}
