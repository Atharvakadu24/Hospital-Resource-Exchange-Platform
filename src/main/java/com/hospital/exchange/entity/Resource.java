package com.hospital.exchange.entity;

import com.hospital.exchange.model.ResourceType;
import jakarta.persistence.*;


@Entity
@Table(name = "resources")
public class Resource {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String resourceName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ResourceType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ResourceStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hospital_id")
    private Hospital hospital;

    public Resource() {}

    public Resource(Long id, String resourceName, ResourceType type, ResourceStatus status, Hospital hospital) {
        this.id = id;
        this.resourceName = resourceName;
        this.type = type;
        this.status = status;
        this.hospital = hospital;
    }

    public enum ResourceStatus {
        AVAILABLE,
        RESERVED,
        IN_USE,
        MAINTENANCE
    }

    // Builder-like approach
    public static ResourceBuilder builder() {
        return new ResourceBuilder();
    }

    public static class ResourceBuilder {
        private Long id;
        private String resourceName;
        private ResourceType type;
        private ResourceStatus status;
        private Hospital hospital;

        public ResourceBuilder id(Long id) { this.id = id; return this; }
        public ResourceBuilder resourceName(String resourceName) { this.resourceName = resourceName; return this; }
        public ResourceBuilder type(ResourceType type) { this.type = type; return this; }
        public ResourceBuilder status(ResourceStatus status) { this.status = status; return this; }
        public ResourceBuilder hospital(Hospital hospital) { this.hospital = hospital; return this; }
        public Resource build() {
            return new Resource(id, resourceName, type, status, hospital);
        }
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getResourceName() { return resourceName; }
    public void setResourceName(String resourceName) { this.resourceName = resourceName; }
    public ResourceType getType() { return type; }
    public void setType(ResourceType type) { this.type = type; }
    public ResourceStatus getStatus() { return status; }
    public void setStatus(ResourceStatus status) { this.status = status; }
    public Hospital getHospital() { return hospital; }
    public void setHospital(Hospital hospital) { this.hospital = hospital; }
}
