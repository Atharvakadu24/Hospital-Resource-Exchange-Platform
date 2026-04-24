package com.hospital.exchange.dto;

/**
 * Data Transfer Object for aggregated hospital resource status.
 * Used for optimizing performance in Map and Dashboard views.
 */
public class HospitalResourceSummaryDTO {
    private int icuTotal;
    private int icuAvail;
    private int ventTotal;
    private int ventAvail;
    private int ambulanceTotal;
    private int ambulanceAvail;
    private int specialistTotal;
    private int specialistAvail;
    
    private String status; // AVAILABLE, LIMITED, CRITICAL
    private int totalAvail;
    private int totalAll;
    private double availabilityRatio;

    public HospitalResourceSummaryDTO() {
    }

    public HospitalResourceSummaryDTO(int icuTotal, int icuAvail, int ventTotal, int ventAvail,
                                      int ambulanceTotal, int ambulanceAvail, int specialistTotal, int specialistAvail,
                                      String status, int totalAvail, int totalAll, double availabilityRatio) {
        this.icuTotal = icuTotal;
        this.icuAvail = icuAvail;
        this.ventTotal = ventTotal;
        this.ventAvail = ventAvail;
        this.ambulanceTotal = ambulanceTotal;
        this.ambulanceAvail = ambulanceAvail;
        this.specialistTotal = specialistTotal;
        this.specialistAvail = specialistAvail;
        this.status = status;
        this.totalAvail = totalAvail;
        this.totalAll = totalAll;
        this.availabilityRatio = availabilityRatio;
    }

    /**
     * Factory method to calculate summary logic consistently across the system.
     */
    public static HospitalResourceSummaryDTO calculate(int icuT, int icuA, int ventT, int ventA, 
                                                      int ambT, int ambA, int specT, int specA) {
        int totalA = icuA + ventA + ambA + specA;
        int totalSum = icuT + ventT + ambT + specT;
        double ratio = totalSum > 0 ? (double) totalA / totalSum : 0;
        
        String calculatedStatus = "CRITICAL";
        if (totalSum > 0) {
            if (ratio >= 0.5) calculatedStatus = "AVAILABLE";
            else if (ratio > 0) calculatedStatus = "LIMITED";
        }

        return new HospitalResourceSummaryDTO(
                icuT,
                icuA,
                ventT,
                ventA,
                ambT,
                ambA,
                specT,
                specA,
                calculatedStatus,
                totalA,
                totalSum,
                ratio
        );
    }

    public int getIcuTotal() {
        return icuTotal;
    }

    public void setIcuTotal(int icuTotal) {
        this.icuTotal = icuTotal;
    }

    public int getIcuAvail() {
        return icuAvail;
    }

    public void setIcuAvail(int icuAvail) {
        this.icuAvail = icuAvail;
    }

    public int getVentTotal() {
        return ventTotal;
    }

    public void setVentTotal(int ventTotal) {
        this.ventTotal = ventTotal;
    }

    public int getVentAvail() {
        return ventAvail;
    }

    public void setVentAvail(int ventAvail) {
        this.ventAvail = ventAvail;
    }

    public int getAmbulanceTotal() {
        return ambulanceTotal;
    }

    public void setAmbulanceTotal(int ambulanceTotal) {
        this.ambulanceTotal = ambulanceTotal;
    }

    public int getAmbulanceAvail() {
        return ambulanceAvail;
    }

    public void setAmbulanceAvail(int ambulanceAvail) {
        this.ambulanceAvail = ambulanceAvail;
    }

    public int getSpecialistTotal() {
        return specialistTotal;
    }

    public void setSpecialistTotal(int specialistTotal) {
        this.specialistTotal = specialistTotal;
    }

    public int getSpecialistAvail() {
        return specialistAvail;
    }

    public void setSpecialistAvail(int specialistAvail) {
        this.specialistAvail = specialistAvail;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getTotalAvail() {
        return totalAvail;
    }

    public void setTotalAvail(int totalAvail) {
        this.totalAvail = totalAvail;
    }

    public int getTotalAll() {
        return totalAll;
    }

    public void setTotalAll(int totalAll) {
        this.totalAll = totalAll;
    }

    public double getAvailabilityRatio() {
        return availabilityRatio;
    }

    public void setAvailabilityRatio(double availabilityRatio) {
        this.availabilityRatio = availabilityRatio;
    }
}
