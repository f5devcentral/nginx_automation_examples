resource "kubernetes_manifest" "dnsendpoints_crd" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.17.1
  name: dnsendpoints.externaldns.nginx.org
spec:
  group: externaldns.nginx.org
  names:
    kind: DNSEndpoint
    listKind: DNSEndpointList
    plural: dnsendpoints
    singular: dnsendpoint
  scope: Namespaced
  versions:
  - name: v1
    schema:
      openAPIV3Schema:
        description: DNSEndpoint is the CRD wrapper for Endpoint
        properties:
          apiVersion:
            description: APIVersion defines the versioned schema of this representation of an object.
            type: string
          kind:
            description: Kind is a string value representing the REST resource this object represents.
            type: string
          metadata:
            type: object
          spec:
            description: DNSEndpointSpec holds information about endpoints.
            properties:
              endpoints:
                items:
                  description: Endpoint describes DNS Endpoint.
                  properties:
                    dnsName:
                      description: The hostname for the DNS record
                      type: string
                    labels:
                      additionalProperties:
                        type: string
                      description: Labels stores labels defined for the Endpoint
                      type: object
                    providerSpecific:
                      description: ProviderSpecific stores provider specific config
                      items:
                        description: ProviderSpecificProperty represents provider specific config property.
                        properties:
                          name:
                            description: Name of the property
                            type: string
                          value:
                            description: Value of the property
                            type: string
                        type: object
                      type: array
                    recordTTL:
                      description: TTL for the record
                      format: int64
                      type: integer
                    recordType:
                      description: RecordType type of record, e.g. CNAME, A, SRV, TXT, MX
                      type: string
                    targets:
                      description: The targets the DNS service points to
                      items:
                        type: string
                      type: array
                  type: object
                type: array
            type: object
          status:
            description: DNSEndpointStatus represents generation observed by the external dns controller.
            properties:
              observedGeneration:
                description: The generation observed by by the external-dns controller.
                format: int64
                type: integer
            type: object
        type: object
    served: true
    storage: true
    subresources:
      status: {}
YAML
  )
}

resource "kubernetes_manifest" "globalconfigurations_crd" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.17.1
  name: globalconfigurations.k8s.nginx.org
spec:
  group: k8s.nginx.org
  names:
    kind: GlobalConfiguration
    listKind: GlobalConfigurationList
    plural: globalconfigurations
    shortNames:
    - gc
    singular: globalconfiguration
  scope: Namespaced
  versions:
  - name: v1
    schema:
      openAPIV3Schema:
        description: GlobalConfiguration defines the GlobalConfiguration resource.
        properties:
          apiVersion:
            description: APIVersion defines the versioned schema of this representation of an object.
            type: string
          kind:
            description: Kind is a string value representing the REST resource this object represents.
            type: string
          metadata:
            type: object
          spec:
            description: GlobalConfigurationSpec is the spec of the GlobalConfiguration resource.
            properties:
              listeners:
                items:
                  description: Listener defines a listener.
                  properties:
                    ipv4:
                      type: string
                    ipv6:
                      type: string
                    name:
                      type: string
                    port:
                      type: integer
                    protocol:
                      type: string
                    ssl:
                      type: boolean
                  type: object
                type: array
            type: object
        type: object
    served: true
    storage: true
YAML
  )
}

resource "kubernetes_manifest" "policies_crd" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.17.1
  name: policies.k8s.nginx.org
spec:
  group: k8s.nginx.org
  names:
    kind: Policy
    listKind: PolicyList
    plural: policies
    shortNames:
    - pol
    singular: policy
  scope: Namespaced
  versions:
  - additionalPrinterColumns:
    - description: Current state of the Policy. If the resource has a valid status, it means it has been validated and accepted by the Ingress Controller.
      jsonPath: .status.state
      name: State
      type: string
    - jsonPath: .metadata.creationTimestamp
      name: Age
      type: date
    name: v1
    schema:
      openAPIV3Schema:
        description: Policy defines a Policy for VirtualServer and VirtualServerRoute resources.
        properties:
          apiVersion:
            description: APIVersion defines the versioned schema of this representation of an object.
            type: string
          kind:
            description: Kind is a string value representing the REST resource this object represents.
            type: string
          metadata:
            type: object
          spec:
            description: PolicySpec is the spec of the Policy resource.
            properties:
              accessControl:
                description: AccessControl defines an access policy based on the source IP of a request.
                properties:
                  allow:
                    items:
                      type: string
                    type: array
                  deny:
                    items:
                      type: string
                    type: array
                type: object
              # ... (other policy properties remain the same) ...
            type: object
          status:
            description: PolicyStatus is the status of the policy resource
            properties:
              message:
                type: string
              reason:
                type: string
              state:
                type: string
            type: object
        type: object
    served: true
    storage: true
    subresources:
      status: {}
YAML
  )
}

resource "kubernetes_manifest" "transportservers_crd" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.17.1
  name: transportservers.k8s.nginx.org
spec:
  group: k8s.nginx.org
  names:
    kind: TransportServer
    listKind: TransportServerList
    plural: transportservers
    shortNames:
    - ts
    singular: transportserver
  scope: Namespaced
  versions:
  - additionalPrinterColumns:
    - description: Current state of the TransportServer. If the resource has a valid status, it means it has been validated and accepted by the Ingress Controller.
      jsonPath: .status.state
      name: State
      type: string
    - jsonPath: .status.reason
      name: Reason
      type: string
    - jsonPath: .metadata.creationTimestamp
      name: Age
      type: date
    name: v1
    schema:
      openAPIV3Schema:
        description: TransportServer defines the TransportServer resource.
        properties:
          # ... (transport server properties remain the same) ...
        type: object
    served: true
    storage: true
    subresources:
      status: {}
YAML
  )
}

resource "kubernetes_manifest" "virtualserverroute_crd" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.17.1
  name: virtualserverroutes.k8s.nginx.org
spec:
  group: k8s.nginx.org
  names:
    kind: VirtualServerRoute
    listKind: VirtualServerRouteList
    plural: virtualserverroutes
    shortNames:
    - vsr
    singular: virtualserverroute
  scope: Namespaced
  versions:
  - additionalPrinterColumns:
    - description: Current state of the VirtualServerRoute. If the resource has a valid status, it means it has been validated and accepted by the Ingress Controller.
      jsonPath: .status.state
      name: State
      type: string
    - jsonPath: .spec.host
      name: Host
      type: string
    - jsonPath: .status.externalEndpoints[*].ip
      name: IP
      type: string
    - jsonPath: .status.externalEndpoints[*].hostname
      name: ExternalHostname
      priority: 1
      type: string
    - jsonPath: .status.externalEndpoints[*].ports
      name: Ports
      type: string
    - jsonPath: .metadata.creationTimestamp
      name: Age
      type: date
    name: v1
    schema:
      openAPIV3Schema:
        description: VirtualServerRoute defines the VirtualServerRoute resource.
        properties:
          # ... (virtual server route properties remain the same) ...
        type: object
    served: true
    storage: true
    subresources:
      status: {}
YAML
  )
}

resource "kubernetes_manifest" "virtualserver_crd" {
  manifest = yamldecode(<<YAML
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.17.1
  name: virtualservers.k8s.nginx.org
spec:
  group: k8s.nginx.org
  names:
    kind: VirtualServer
    listKind: VirtualServerList
    plural: virtualservers
    shortNames:
    - vs
    singular: virtualserver
  scope: Namespaced
  versions:
  - additionalPrinterColumns:
    - description: Current state of the VirtualServer. If the resource has a valid status, it means it has been validated and accepted by the Ingress Controller.
      jsonPath: .status.state
      name: State
      type: string
    - jsonPath: .spec.host
      name: Host
      type: string
    - jsonPath: .status.externalEndpoints[*].ip
      name: IP
      type: string
    - jsonPath: .status.externalEndpoints[*].hostname
      name: ExternalHostname
      priority: 1
      type: string
    - jsonPath: .status.externalEndpoints[*].ports
      name: Ports
      type: string
    - jsonPath: .metadata.creationTimestamp
      name: Age
      type: date
    name: v1
    schema:
      openAPIV3Schema:
        description: VirtualServer defines the VirtualServer resource.
        properties:
          # ... (virtual server properties remain the same) ...
        type: object
    served: true
    storage: true
    subresources:
      status: {}
YAML
  )
}
