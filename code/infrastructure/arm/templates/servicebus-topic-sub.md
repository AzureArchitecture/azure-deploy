# ServiceBus Topic Subscription

Creates a Subscription for an existing ServiceBus Topic.

## Parameters

ServiceBusNamespaceName: (required) string

Name of an existing ServiceBus to create the topic in.

ServiceBusTopicName: (required) string

Name of the existing Topic in the Service Bus to add the subsciption to.

ServiceBusTopicSubName: (required) string

Name of the Subscription.

SubscriptionSqlFilter: (optional) string

A SQL filter to add to the subscription.
Creates a rule with filterType of SqlFilter if specified.
Does not create a rule if no filter is specified or it is empty.
