resource "kubectl_manifest" "dnsendpoints_crd" {
  yaml_body = <<YAML
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
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        description: DNSEndpoint is the CRD wrapper for Endpoint
        properties:
          apiVersion:
            description: API version of the object
            type: string
          kind:
            description: Kind of the object
            type: string
          metadata:
            type: object
          spec:
            description: DNSEndpointSpec holds information about endpoints.
            properties:
              endpoints:
                type: array
                items:
                  type: object
                  properties:
                    dnsName:
                      type: string
                    labels:
                      type: object
                      additionalProperties:
                        type: string
                    providerSpecific:
                      type: array
                      items:
                        type: object
                        properties:
                          name:
                            type: string
                          value:
                            type: string
                    recordTTL:
                      type: integer
                      format: int64
                    recordType:
                      type: string
                    targets:
                      type: array
                      items:
                        type: string
            type: object
          status:
            properties:
              observedGeneration:
                type: integer
                format: int64
            type: object
        type: object
    subresources:
      status: {}
YAML
}

resource "kubectl_manifest" "globalconfigurations_crd" {
  yaml_body = <<YAML
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
    singular: globalconfiguration
    shortNames: ["gc"]
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        description: GlobalConfiguration defines the GlobalConfiguration resource.
        properties:
          spec:
            properties:
              listeners:
                type: array
                items:
                  type: object
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
        type: object
YAML
}

resource "kubectl_manifest" "policies_crd" {
  yaml_body = <<YAML
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
    singular: policy
    shortNames: ["pol"]
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    additionalPrinterColumns:
    - jsonPath: .status.state
      name: State
      type: string
    - jsonPath: .metadata.creationTimestamp
      name: Age
      type: date
    schema:
      openAPIV3Schema:
        properties:
          spec:
            properties:
              accessControl:
                properties:
                  allow:
                    type: array
                    items:
                      type: string
                  deny:
                    type: array
                    items:
                      type: string
                type: object
              waf:
                properties:
                  apPolicy:
                    type: string
                  enable:
                    type: boolean
                type: object
            type: object
          status:
            properties:
              state:
                type: string
            type: object
        type: object
    subresources:
      status: {}
YAML
}

resource "kubectl_manifest" "transportservers_crd" {
  yaml_body = <<YAML
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
    shortNames: ["ts"]
    singular: transportserver
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    additionalPrinterColumns:
    - jsonPath: .status.state
      name: State
      type: string
    - jsonPath: .status.reason
      name: Reason
      type: string
    - jsonPath: .metadata.creationTimestamp
      name: Age
      type: date
    schema:
      openAPIV3Schema:
        properties:
          spec:
            properties:
              host:
                type: string
              upstreams:
                type: array
                items:
                  type: object
                  properties:
                    name:
                      type: string
                    service:
                      type: string
            type: object
          status:
            properties:
              state:
                type: string
            type: object
        type: object
    subresources:
      status: {}
YAML
}

resource "kubectl_manifest" "virtualserverroute_crd" {
  yaml_body = <<YAML
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
    shortNames: ["vsr"]
    singular: virtualserverroute
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    additionalPrinterColumns:
    - jsonPath: .status.state
      name: State
      type: string
    - jsonPath: .spec.host
      name: Host
      type: string
    schema:
      openAPIV3Schema:
        properties:
          spec:
            properties:
              subroutes:
                type: array
                items:
                  type: object
                  properties:
                    path:
                      type: string
            type: object
        type: object
    subresources:
      status: {}
YAML
}

resource "kubectl_manifest" "virtualserver_crd" {
  yaml_body = <<YAML
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
    shortNames: ["vs"]
    singular: virtualserver
  scope: Namespaced
  versions:
  - name: v1
    served: true
    storage: true
    additionalPrinterColumns:
    - jsonPath: .status.state
      name: State
      type: string
    schema:
      openAPIV3Schema:
        properties:
          spec:
            properties:
              host:
                type: string
              routes:
                type: array
                items:
                  type: object
                  properties:
                    path:
                      type: string
            type: object
        type: object
    subresources:
      status: {}
YAML
}
