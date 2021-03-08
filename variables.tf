variable "region" {
  default = "eu-west-1"
  type = string
}

variable "aws_key" {
  type = string
}
variable "aws_secret" {
  type = string
  sensitive = true
}

variable "domain" {
    description = "your domain"
  default = "techunter.io"
  type = string
}

variable "appname" {
    description = "subdomain to map to the container ingress"
  type = string
  default = "valheim"
}

variable "subnet_zones" {
  description = "Set of availability zones to the number that should be used for each availability zone's subnet"
  default     = {"eu-west-1a": 1, "eu-west-1b": 2, "eu-west-1c": 3}
}

variable "ports" {
  description = "UDP Ports to expose"
  default = [[2456, "udp"], [2457, "udp"], [2458,"udp"]]
}

variable "container" {
    description = "Map of container resource reservation. This impact the billing plan"
    default = {
        image = "mbround18/valheim:latest",
        # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
        memory = 2048,
        cpu = 1024,
        # https://github.com/mbround18/valheim-docker
        environment = {
            PORT="2456",
            NAME="Valheim Server Name", # display name for server list
            WORLD="Valheim World Name", # display name ingame
            PASSWORD="Strong! Password @ Here", # password minimum 6 chars
            TZ="Europe/Paris", # Timezone
            PUBLIC="1", #public
            #AUTO_UPDATE="1",
            AUTO_UPDATE_SCHEDULE="0 4 * * *",
            #AUTO_BACKUP="1",
            AUTO_BACKUP_SCHEDULE="*/15 * * * *",
            #AUTO_BACKUP_REMOVE_OLD="1",
            #AUTO_BACKUP_DAYS_TO_LIVE="3",
            #AUTO_BACKUP_ON_UPDATE="1",
            #AUTO_BACKUP_ON_SHUTDOWN="1",
            #WEBHOOK_URL="https://discord.com/api/webhooks/IM_A_SNOWFLAKE/AND_I_AM_A_SECRET",
            UPDATE_ON_STARTUP="1"
        },
        volumes = {
                "valheim-saves": {host_path: "/home/steam/.config/unity3d/IronGate/Valheim"},
                "valheim-server": {host_path: "/home/steam/valheim"},
                "valheim-backups": {host_path: "/home/steam/backups"}
        }
        
    }
}