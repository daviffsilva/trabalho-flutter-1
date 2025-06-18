package com.entregas.gateway.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public class TokenValidationResponse {
    @JsonProperty("valid")
    private Boolean valid;
    
    @JsonProperty("userId")
    private String userId;
    
    @JsonProperty("userType")
    private String userType;
    
    @JsonProperty("error")
    private String error;

    public TokenValidationResponse() {}

    public TokenValidationResponse(Boolean valid, String userId, String userType, String error) {
        this.valid = valid;
        this.userId = userId;
        this.userType = userType;
        this.error = error;
    }

    public Boolean getValid() {
        return valid;
    }

    public void setValid(Boolean valid) {
        this.valid = valid;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserType() {
        return userType;
    }

    public void setUserType(String userType) {
        this.userType = userType;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }
} 