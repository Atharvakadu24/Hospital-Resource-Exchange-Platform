package com.hospital.exchange.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "bookings")
public class Booking {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "request_id", nullable = false)
    private AllocationRequest request;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "resource_id", nullable = false)
    private Resource resource;

    @Column(nullable = false)
    private LocalDateTime confirmedAt;

    @Column(nullable = false)
    private LocalDateTime releaseAt;

    @Column(nullable = false)
    private boolean released;

    public Booking() {}

    public Booking(Long id, AllocationRequest request, Resource resource, LocalDateTime confirmedAt, LocalDateTime releaseAt, boolean released) {
        this.id = id;
        this.request = request;
        this.resource = resource;
        this.confirmedAt = confirmedAt;
        this.releaseAt = releaseAt;
        this.released = released;
    }

    // Builder
    public static BookingBuilder builder() {
        return new BookingBuilder();
    }

    public static class BookingBuilder {
        private Long id;
        private AllocationRequest request;
        private Resource resource;
        private LocalDateTime confirmedAt;
        private LocalDateTime releaseAt;
        private boolean released;

        public BookingBuilder id(Long id) { this.id = id; return this; }
        public BookingBuilder request(AllocationRequest request) { this.request = request; return this; }
        public BookingBuilder resource(Resource resource) { this.resource = resource; return this; }
        public BookingBuilder confirmedAt(LocalDateTime confirmedAt) { this.confirmedAt = confirmedAt; return this; }
        public BookingBuilder releaseAt(LocalDateTime releaseAt) { this.releaseAt = releaseAt; return this; }
        public BookingBuilder released(boolean released) { this.released = released; return this; }
        public Booking build() {
            return new Booking(id, request, resource, confirmedAt, releaseAt, released);
        }
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public AllocationRequest getRequest() { return request; }
    public void setRequest(AllocationRequest request) { this.request = request; }
    public Resource getResource() { return resource; }
    public void setResource(Resource resource) { this.resource = resource; }
    public LocalDateTime getConfirmedAt() { return confirmedAt; }
    public void setConfirmedAt(LocalDateTime confirmedAt) { this.confirmedAt = confirmedAt; }
    public LocalDateTime getReleaseAt() { return releaseAt; }
    public void setReleaseAt(LocalDateTime releaseAt) { this.releaseAt = releaseAt; }
    public boolean isReleased() { return released; }
    public void setReleased(boolean released) { this.released = released; }
}
