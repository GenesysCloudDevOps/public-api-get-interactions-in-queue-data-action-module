resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "properties" = {
            "MEDIA_TYPE" = {
                "description" = "The media type of the interaction: voice, chat, callback, email, social media, or video communication.",
                "enum" = [
                    "voice",
                    "chat",
                    "callback",
                    "email",
                    "socialExpression",
                    "videoComm"
                ],
                "type" = "string"
            },
            "QUEUE_ID" = {
                "description" = "The queue ID.",
                "type" = "string"
            }
        },
        "required" = [
            "QUEUE_ID",
            "MEDIA_TYPE"
        ],
        "type" = "object"
    })
    contract_output = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "properties" = {
            "NUM_INTERACTING" = {
                "description" = "Interactions in the queue assigned to agents",
                "type" = "number"
            },
            "NUM_WAITING" = {
                "description" = "Interactions in the queue waiting",
                "type" = "number"
            }
        },
        "type" = "object"
    })
    
    config_request {
        request_template     = "{\"filter\": {\"type\":\"and\",\"predicates\": [{\"dimension\": \"queueId\",\"value\": \"$${input.QUEUE_ID}\"},{\"dimension\": \"mediaType\",\"value\": \"$${input.MEDIA_TYPE}\"}]},\"metrics\": [\"oWaiting\",\"oInteracting\"]}"
        request_type         = "POST"
        request_url_template = "/api/v2/analytics/queues/observations/query"
        headers = {
			Content-Type = "application/json"
		}
    }

    config_response {
        success_template = "{\"NUM_INTERACTING\": $${successTemplateUtils.firstFromArray(\"$${NumInteracting}\", \"0\")}, \"NUM_WAITING\": $${successTemplateUtils.firstFromArray(\"$${NumWaiting}\", \"0\")}}"
        translation_map = { 
			NumWaiting = "$..data[?(@.metric==\"oWaiting\")].stats.count"
			NumInteracting = "$..data[?(@.metric==\"oInteracting\")].stats.count"
		}
               
    }
}