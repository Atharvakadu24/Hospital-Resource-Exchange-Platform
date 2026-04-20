package com.hospital.exchange.entity;

import jakarta.persistence.*;

import java.util.List;

@Entity
@Table(name = "hospitals")
public class Hospital {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    @Column(nullable = false)
    private String location;

    @Column(nullable = false)
    private String contactNumber;

    @Column(nullable = false)
    private String contactEmail;

    @Column(nullable = false)
    private Integer resourceQuota;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @OneToMany(mappedBy = "hospital", cascade = CascadeType.ALL)
    private List<Resource> resources;

    public Hospital() {}

    public Hospital(Long id, String name, String location, String contactNumber, String contactEmail, Integer resourceQuota, Double latitude, Double longitude) {
        this.id = id;
        this.name = name;
        this.location = location;
        this.contactNumber = contactNumber;
        this.contactEmail = contactEmail;
        this.resourceQuota = resourceQuota;
        this.latitude = latitude;
        this.longitude = longitude;
    }

    // Builder-like approach for existing code
    public static HospitalBuilder builder() {
        return new HospitalBuilder();
    }

    public static class HospitalBuilder {
        private Long id;
        private String name;
        private String location;
        private String contactNumber;
        private String contactEmail;
        private Integer resourceQuota;
        private Double latitude;
        private Double longitude;

        public HospitalBuilder id(Long id) { this.id = id; return this; }
        public HospitalBuilder name(String name) { this.name = name; return this; }
        public HospitalBuilder location(String location) { this.location = location; return this; }
        public HospitalBuilder contactNumber(String contactNumber) { this.contactNumber = contactNumber; return this; }
        public HospitalBuilder contactEmail(String contactEmail) { this.contactEmail = contactEmail; return this; }
        public HospitalBuilder contactInfo(String contactInfo) { // For compatibility with simulation tests
            this.contactEmail = contactInfo;
            this.contactNumber = contactInfo;
            return this;
        }
        public HospitalBuilder resourceQuota(Integer resourceQuota) { this.resourceQuota = resourceQuota; return this; }
        public HospitalBuilder latitude(Double latitude) { this.latitude = latitude; return this; }
        public HospitalBuilder longitude(Double longitude) { this.longitude = longitude; return this; }
        public Hospital build() {
            return new Hospital(id, name, location, contactNumber, contactEmail, resourceQuota, latitude, longitude);
        }
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }
    public String getContactEmail() { return contactEmail; }
    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }
    public Integer getResourceQuota() { return resourceQuota; }
    public void setResourceQuota(Integer resourceQuota) { this.resourceQuota = resourceQuota; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public List<Resource> getResources() { return resources; }
    public void setResources(List<Resource> resources) { this.resources = resources; }
}
