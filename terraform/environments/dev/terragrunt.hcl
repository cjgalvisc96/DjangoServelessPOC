include {
    path = find_in_parent_folders()
}

terraform {
    source = "../..//src"
}


inputs = {
    # Module: Network
    aws_vpc__cidr_block                      = "10.0.0.0/16"
    aws_vpc__enable_dns_support              = true
    aws_vpc__enable_dns_hostnames            = true

    aws_subnet__public_cidr_blocks           = ["10.0.1.0/24", "10.0.2.0/24"]
    aws_subnet__private_cidr_blocks          = ["10.0.3.0/24", "10.0.4.0/24"]
    aws_subnet__availability_zones           = ["us-east-1a", "us-east-1b"]

    aws_route__destination_cidr_block        = "0.0.0.0/0"

    aws_eip__vpc                             = true
    aws_eip__associate_with_private_ip       = "10.0.0.5"
    # Module: Compute
}