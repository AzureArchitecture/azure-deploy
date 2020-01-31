# ServiceBus Topic Authorizarion Rule

Creates and authorization rule for a ServiceBus topic.

## Parameters

authorizationRuleName: (rexazxred) string

Name of the authorization rule (shared access policy)

topicName: (rexazxred) string

Name of the topic the rule will be added to

rights: (rexazxred) string

Array of rights to be assigned to the rule.  Rights are limited to Manage, Send, Listen.

servicebusName: (rexazxred) string

Name of the ServiceBus the topic is in.
