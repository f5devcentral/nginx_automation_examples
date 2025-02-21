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
          type: object
          description: DNSEndpoint is the CRD wrapper for Endpoint
          properties:
            apiVersion:
              type: string
              description: API version of the object
            kind:
              type: string
              description: Kind of the object
            metadata:
              type: object
            spec:
              type: object
              description: DNSEndpointSpec holds information about endpoints.
              properties:
                endpoints:
                  type: array
                  items:
                    type: object
                    description: Endpoint describes a DNS Endpoint.
                    properties:
                      dnsName:
                        type: string
                        description: The hostname for the DNS record
                      labels:
                        type: object
                        additionalProperties:
                          type: string
                        description: Labels defined for the Endpoint
                      providerSpecific:
                        type: array
                        description: Provider-specific configurations
                        items:
                          type: object
                          properties:
                            name:
                              type: string
                              description: Name of the property
                            value:
                              type: string
                              description: Value of the property
                      recordTTL:
                        type: integer
                        format: int64
                        description: TTL for the record
                      recordType:
                        type: string
                        description: Type of record (e.g., CNAME, A, TXT)
                      targets:
                        type: array
                        items:
                          type: string
                        description: The targets the DNS service points to
            status:
              type: object
              properties:
                observedGeneration:
                  type: integer
                  format: int64
                  description: Observed generation by external DNS controller
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
    shortNames:
      - gc
  scope: Namespaced
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          description: GlobalConfiguration defines the GlobalConfiguration resource.
          properties:
            apiVersion:
              type: string
              description: API version of the object
            kind:
              type: string
              description: Kind of the object
            metadata:
              type: object
            spec:
              type: object
              description: GlobalConfigurationSpec holds configuration details.
              properties:
                listeners:
                  type: array
                  description: List of listeners.
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
    shortNames:
      - pol
    singular: policy
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
          type: object
          properties:
            spec:
              type: object
              properties:
                ingressClassName:
                  type: string
                accessControl:
                  type: object
                  properties:
                    allow:
                      type: array
                      items:
                        type: string
                    deny:
                      type: array
                      items:
                        type: string
                waf:
                  type: object
                  properties:
                    apPolicy:
                      type: string
                    enable:
                      type: boolean
            status:
              type: object
              properties:
                state:
                  type: string
                message:
                  type: string
                reason:
                  type: string
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
    shortNames:
      - ts
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
          type: object
          properties:
            spec:
              type: object
              properties:
                host:
                  type: string
                ingressClassName:
                  type: string
                listener:
                  type: object
                  properties:
                    name:
                      type: string
                    protocol:
                      type: string
                tls:
                  type: object
                  properties:
                    secret:
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
                      port:
                        type: integer
            status:
              type: object
              properties:
                state:
                  type: string
                reason:
                  type: string
      subresources:
        status: {}
YAML
}

resource "kubernetes_manifest" "virtualserverroute_crd" {
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
    schema:
      openAPIV3Schema:
        description: VirtualServerRoute defines the VirtualServerRoute resource.
        type: object
        properties:
          apiVersion:
            type: string
            description: APIVersion defines the versioned schema of this representation of an object.
          kind:
            type: string
            description: Kind is a string value representing the REST resource this object represents.
          metadata:
            type: object
          spec:
            type: object
            description: VirtualServerRouteSpec is the spec of the VirtualServerRoute resource.
            properties:
              host:
                type: string
              ingressClassName:
                type: string
              subroutes:
                type: array
                items:
                  type: object
                  description: Route defines a route.
                  properties:
                    action:
                      type: object
                      description: Action defines an action.
                      properties:
                        pass:
                          type: string
                        proxy:
                          type: object
                          description: ActionProxy defines a proxy in an Action.
                          properties:
                            requestHeaders:
                              type: object
                              description: ProxyRequestHeaders defines the request headers manipulation.
                              properties:
                                pass:
                                  type: boolean
                                set:
                                  type: array
                                  items:
                                    type: object
                                    description: Header defines an HTTP Header.
                                    properties:
                                      name:
                                        type: string
                                      value:
                                        type: string
                            responseHeaders:
                              type: object
                              description: ProxyResponseHeaders defines the response headers manipulation.
                              properties:
                                add:
                                  type: array
                                  items:
                                    type: object
                                    description: AddHeader defines an HTTP Header with optional Always field.
                                    properties:
                                      always:
                                        type: boolean
                                      name:
                                        type: string
                                      value:
                                        type: string
                                hide:
                                  type: array
                                  items:
                                    type: string
                                ignore:
                                  type: array
                                  items:
                                    type: string
                                pass:
                                  type: array
                                  items:
                                    type: string
                            rewritePath:
                              type: string
                            upstream:
                              type: string
                        redirect:
                          type: object
                          description: ActionRedirect defines a redirect in an Action.
                          properties:
                            code:
                              type: integer
                            url:
                              type: string
                        return:
                          type: object
                          description: ActionReturn defines a return in an Action.
                          properties:
                            body:
                              type: string
                            code:
                              type: integer
                            headers:
                              type: array
                              items:
                                type: object
                                description: Header defines an HTTP Header.
                                properties:
                                  name:
                                    type: string
                                  value:
                                    type: string
                            type:
                              type: string
                    dos:
                      type: string
                    errorPages:
                      type: array
                      items:
                        type: object
                        description: ErrorPage defines an ErrorPage in a Route.
                        properties:
                          codes:
                            type: array
                            items:
                              type: integer
                          redirect:
                            type: object
                            description: ErrorPageRedirect defines a redirect for an ErrorPage.
                            properties:
                              code:
                                type: integer
                              url:
                                type: string
                          return:
                            type: object
                            description: ErrorPageReturn defines a return for an ErrorPage.
                            properties:
                              body:
                                type: string
                              code:
                                type: integer
                              headers:
                                type: array
                                items:
                                  type: object
                                  description: Header defines an HTTP Header.
                                  properties:
                                    name:
                                      type: string
                                    value:
                                      type: string
                              type:
                                type: string
                    location-snippets:
                      type: string
                    matches:
                      type: array
                      items:
                        type: object
                        description: Match defines a match.
                        properties:
                          action:
                            type: object
                            description: Action defines an action.
                            properties:
                              pass:
                                type: string
                              proxy:
                                type: object
                              redirect:
                                type: object
                              return:
                                type: object
                          conditions:
                            type: array
                            items:
                              type: object
                              description: Condition defines a condition in a MatchRule.
                              properties:
                                argument:
                                  type: string
                                cookie:
                                  type: string
                                header:
                                  type: string
                                value:
                                  type: string
                                variable:
                                  type: string
                          splits:
                            type: array
                            items:
                              type: object
                              description: Split defines a split.
                              properties:
                                action:
                                  type: object
                                weight:
                                  type: integer
                    path:
                      type: string
                    policies:
                      type: array
                      items:
                        type: object
                        description: PolicyReference references a policy.
                        properties:
                          name:
                            type: string
                          namespace:
                            type: string
                    route:
                      type: string
                    splits:
                      type: array
                      items:
                        type: object
                        description: Split defines a split.
                        properties:
                          action:
                            type: object
                          weight:
                            type: integer
              upstreams:
                type: array
                items:
                  type: object
                  description: Upstream defines an upstream.
                  properties:
                    backup:
                      type: string
                    backupPort:
                      type: integer
                    buffer-size:
                      type: string
                    buffering:
                      type: boolean
                    buffers:
                      type: object
                      properties:
                        number:
                          type: integer
                        size:
                          type: string
                    client-max-body-size:
                      type: string
                    connect-timeout:
                      type: string
                    fail-timeout:
                      type: string
                    healthCheck:
                      type: object
                      properties:
                        connect-timeout:
                          type: string
                        enable:
                          type: boolean
                        fails:
                          type: integer
                        grpcService:
                          type: string
                        grpcStatus:
                          type: integer
                        headers:
                          type: array
                          items:
                            type: object
                            properties:
                              name:
                                type: string
                              value:
                                type: string
                        interval:
                          type: string
                        jitter:
                          type: string
                        keepalive-time:
                          type: string
                        mandatory:
                          type: boolean
                        passes:
                          type: integer
                        path:
                          type: string
                        persistent:
                          type: boolean
                        port:
                          type: integer
                        read-timeout:
                          type: string
                        send-timeout:
                          type: string
                        statusMatch:
                          type: string
                        tls:
                          type: object
                          properties:
                            enable:
                              type: boolean
                    keepalive:
                      type: integer
                    lb-method:
                      type: string
                    max-conns:
                      type: integer
                    max-fails:
                      type: integer
                    name:
                      type: string
                    next-upstream:
                      type: string
                    next-upstream-timeout:
                      type: string
                    next-upstream-tries:
                      type: integer
                    ntlm:
                      type: boolean
                    port:
                      type: integer
                    queue:
                      type: object
                      properties:
                        size:
                          type: integer
                        timeout:
                          type: string
                    read-timeout:
                      type: string
                    send-timeout:
                      type: string
                    service:
                      type: string
                    sessionCookie:
                      type: object
                      properties:
                        domain:
                          type: string
                        enable:
                          type: boolean
                        expires:
                          type: string
                        httpOnly:
                          type: boolean
                        name:
                          type: string
                        path:
                          type: string
                        samesite:
                          type: string
                        secure:
                          type: boolean
                    slow-start:
                      type: string
                    subselector:
                      type: object
                      additionalProperties:
                        type: string
                    tls:
                      type: object
                      properties:
                        enable:
                          type: boolean
                    type:
                      type: string
                    use-cluster-ip:
                      type: boolean
          status:
            type: object
            description: VirtualServerRouteStatus defines the status for the VirtualServerRoute resource.
            properties:
              externalEndpoints:
                type: array
                items:
                  type: object
                  description: ExternalEndpoint defines the IP/Hostname and ports used to connect to this resource.
                  properties:
                    hostname:
                      type: string
                    ip:
                      type: string
                    ports:
                      type: string
              message:
                type: string
              reason:
                type: string
              referencedBy:
                type: string
              state:
                type: string
    subresources:
      status: {}
YAML
}

resource "kubernetes_manifest" "virtualserver_crd" {
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
    schema:
      openAPIV3Schema:
        description: VirtualServer defines the VirtualServer resource.
        type: object
        properties:
          apiVersion:
            type: string
            description: APIVersion defines the versioned schema of this representation of an object.
          kind:
            type: string
            description: Kind is a string value representing the REST resource this object represents.
          metadata:
            type: object
          spec:
            type: object
            description: VirtualServerSpec is the spec of the VirtualServer resource.
            properties:
              dos:
                type: string
              externalDNS:
                type: object
                description: ExternalDNS defines externaldns sub-resource of a virtual server.
                properties:
                  enable:
                    type: boolean
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
              gunzip:
                type: boolean
              host:
                type: string
              http-snippets:
                type: string
              ingressClassName:
                type: string
              internalRoute:
                type: boolean
              listener:
                type: object
                properties:
                  http:
                    type: string
                  https:
                    type: string
              policies:
                type: array
                items:
                  type: object
                  properties:
                    name:
                      type: string
                    namespace:
                      type: string
              routes:
                type: array
                items:
                  type: object
                  description: Route defines a route.
                  properties:
                    action:
                      type: object
                      properties:
                        pass:
                          type: string
                        proxy:
                          type: object
                          properties:
                            requestHeaders:
                              type: object
                              properties:
                                pass:
                                  type: boolean
                                set:
                                  type: array
                                  items:
                                    type: object
                                    properties:
                                      name:
                                        type: string
                                      value:
                                        type: string
                            responseHeaders:
                              type: object
                              properties:
                                add:
                                  type: array
                                  items:
                                    type: object
                                    properties:
                                      always:
                                        type: boolean
                                      name:
                                        type: string
                                      value:
                                        type: string
                                hide:
                                  type: array
                                  items:
                                    type: string
                                ignore:
                                  type: array
                                  items:
                                    type: string
                                pass:
                                  type: array
                                  items:
                                    type: string
                            rewritePath:
                              type: string
                            upstream:
                              type: string
                        redirect:
                          type: object
                          properties:
                            code:
                              type: integer
                            url:
                              type: string
                        return:
                          type: object
                          properties:
                            body:
                              type: string
                            code:
                              type: integer
                            headers:
                              type: array
                              items:
                                type: object
                                properties:
                                  name:
                                    type: string
                                  value:
                                    type: string
                            type:
                              type: string
                    errorPages:
                      type: array
                      items:
                        type: object
                        properties:
                          codes:
                            type: array
                            items:
                              type: integer
                          redirect:
                            type: object
                            properties:
                              code:
                                type: integer
                              url:
                                type: string
                          return:
                            type: object
                            properties:
                              body:
                                type: string
                              code:
                                type: integer
                              headers:
                                type: array
                                items:
                                  type: object
                                  properties:
                                    name:
                                      type: string
                                    value:
                                      type: string
                              type:
                                type: string
                    location-snippets:
                      type: string
                    matches:
                      type: array
                      items:
                        type: object
                        properties:
                          action:
                            type: object
                            properties: {}
                          conditions:
                            type: array
                            items:
                              type: object
                              properties:
                                argument:
                                  type: string
                                cookie:
                                  type: string
                                header:
                                  type: string
                                value:
                                  type: string
                                variable:
                                  type: string
                          splits:
                            type: array
                            items:
                              type: object
                              properties:
                                action:
                                  type: object
                                weight:
                                  type: integer
                    path:
                      type: string
                    policies:
                      type: array
                      items:
                        type: object
                        properties:
                          name:
                            type: string
                          namespace:
                            type: string
                    route:
                      type: string
                    splits:
                      type: array
                      items:
                        type: object
                        properties:
                          action:
                            type: object
                          weight:
                            type: integer
              server-snippets:
                type: string
              tls:
                type: object
                properties:
                  cert-manager:
                    type: object
                    properties:
                      cluster-issuer:
                        type: string
                      common-name:
                        type: string
                      duration:
                        type: string
                      issue-temp-cert:
                        type: boolean
                      issuer:
                        type: string
                      issuer-group:
                        type: string
                      issuer-kind:
                        type: string
                      renew-before:
                        type: string
                      usages:
                        type: string
                  redirect:
                    type: object
                    properties:
                      basedOn:
                        type: string
                      code:
                        type: integer
                      enable:
                        type: boolean
                  secret:
                    type: string
              upstreams:
                type: array
                items:
                  type: object
                  properties:
                    backup:
                      type: string
                    backupPort:
                      type: integer
                    buffer-size:
                      type: string
                    buffering:
                      type: boolean
                    buffers:
                      type: object
                      properties:
                        number:
                          type: integer
                        size:
                          type: string
                    client-max-body-size:
                      type: string
                    connect-timeout:
                      type: string
                    fail-timeout:
                      type: string
                    healthCheck:
                      type: object
                      properties:
                        connect-timeout:
                          type: string
                        enable:
                          type: boolean
                        fails:
                          type: integer
                        grpcService:
                          type: string
                        grpcStatus:
                          type: integer
                        headers:
                          type: array
                          items:
                            type: object
                            properties:
                              name:
                                type: string
                              value:
                                type: string
                        interval:
                          type: string
                        jitter:
                          type: string
                        keepalive-time:
                          type: string
                        mandatory:
                          type: boolean
                        passes:
                          type: integer
                        path:
                          type: string
                        persistent:
                          type: boolean
                        port:
                          type: integer
                        read-timeout:
                          type: string
                        send-timeout:
                          type: string
                        statusMatch:
                          type: string
                        tls:
                          type: object
                          properties:
                            enable:
                              type: boolean
                    keepalive:
                      type: integer
                    lb-method:
                      type: string
                    max-conns:
                      type: integer
                    max-fails:
                      type: integer
                    name:
                      type: string
                    next-upstream:
                      type: string
                    next-upstream-timeout:
                      type: string
                    next-upstream-tries:
                      type: integer
                    ntlm:
                      type: boolean
                    port:
                      type: integer
                    queue:
                      type: object
                      properties:
                        size:
                          type: integer
                        timeout:
                          type: string
                    read-timeout:
                      type: string
                    send-timeout:
                      type: string
                    service:
                      type: string
                    sessionCookie:
                      type: object
                      properties:
                        domain:
                          type: string
                        enable:
                          type: boolean
                        expires:
                          type: string
                        httpOnly:
                          type: boolean
                        name:
                          type: string
                        path:
                          type: string
                        samesite:
                          type: string
                        secure:
                          type: boolean
                    slow-start:
                      type: string
                    subselector:
                      type: object
                      additionalProperties:
                        type: string
                    tls:
                      type: object
                      properties:
                        enable:
                          type: boolean
                    type:
                      type: string
                    use-cluster-ip:
                      type: boolean
          status:
            type: object
            description: VirtualServerStatus defines the status for the VirtualServer resource.
            properties:
              externalEndpoints:
                type: array
                items:
                  type: object
                  properties:
                    hostname:
                      type: string
                    ip:
                      type: string
                    ports:
                      type: string
              message:
                type: string
              reason:
                type: string
              state:
                type: string
    subresources:
      status: {}
YAML
}




