variable "my_ip" {
  description = "Your public IP address (for SSH access only)"
  type        = string
  default     = "0.0.0.0/0"   # CHANGE THIS! Use your actual IP
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}