{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cloudbees-flow.name" -}}
{{- default "cloudbees-flow" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cloudbees-flow.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "cloudbees-flow" .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cloudbees-flow.chart" -}}
{{- printf "%s-%s" "cloudbees-flow" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Build DOIS nodes list
*/}}
{{- define "dois.nodes" -}}
{{- $count := .Values.dois.replicas | int -}}
{{- range $i, $e := until $count}}flow-devopsinsight-{{$i}}.flow-devopsinsight,
{{- end -}}
{{- end -}}

{{/*
Define Random Flow Credentials
*/}}
{{- define "server.cbfServerAdminPassword" -}}
{{- if .Values.flowCredentials.adminPassword }}
    {{- .Values.flowCredentials.adminPassword | b64enc | quote  -}}
{{- else -}}
    {{- $secretName := printf "%s-%s" (include "cloudbees-flow.fullname" .) "credentials" }}
    {{- $password := (randAlpha 20) | b64enc | quote }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
    {{- if $secret }}
      {{- if (index $secret.data "CBF_SERVER_ADMIN_PASSWORD") }}
        {{- $password = index $secret.data "CBF_SERVER_ADMIN_PASSWORD" }}
      {{- end -}}
    {{- end -}}
    {{- $password }}
{{- end -}}
{{- end -}}

{{/*
Define Random DOIS Credentials
*/}}
{{- define "dois.cbfReportUserPassword" -}}
{{- if .Values.dois.credentials.reportUserPassword }}
    {{- .Values.dois.credentials.reportUserPassword | b64enc | quote  -}}
{{- else -}}
    {{- $doisSecretName := printf "%s-%s" (include "cloudbees-flow.fullname" .) "dois" }}
    {{- $doisSecret := (lookup "v1" "Secret" .Release.Namespace $doisSecretName) }}
    {{- $password := (randAlpha 20) | b64enc | quote }}
    {{- if $doisSecret }}
      {{- if (index $doisSecret.data "CBF_DOIS_PASSWORD") }}
        {{- $password = index $doisSecret.data "CBF_DOIS_PASSWORD" }}
      {{- end -}}
    {{- end -}}
    {{- $password }}
{{- end -}}
{{- end -}}

{{- define "dois.cbfAdminPassword" -}}
{{- if .Values.dois.credentials.adminPassword }}
    {{- .Values.dois.credentials.adminPassword | b64enc | quote  -}}
{{- else -}}
    {{- $doisAdminSecretName := printf "%s-%s" (include "cloudbees-flow.fullname" .) "dois" }}
    {{- $doisAdminSecret := (lookup "v1" "Secret" .Release.Namespace $doisAdminSecretName) }}
    {{- $password := (randAlpha 20) | b64enc | quote }}
    {{- if $doisAdminSecret }}
      {{- if (index $doisAdminSecret.data "CBF_DOIS_ADMIN_PASSWORD") }}
        {{- $password = index $doisAdminSecret.data "CBF_DOIS_ADMIN_PASSWORD" }}
      {{- end -}}
    {{- end -}}
    {{- $password }}

{{- end -}}
{{- end -}}

{{/*
Define Random Database Credentials
*/}}
{{- define "database.dbPassword" -}}
{{- if .Values.database.dbPassword }}
    {{- .Values.database.dbPassword | b64enc -}}
{{- else -}}
    {{- $secretName := printf "%s-%s" (include "cloudbees-flow.fullname" .) "db" }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
    {{- $password := (randAlpha 20) | b64enc }}
    {{- if $secret }}
      {{- if (index $secret.data "DB_PASSWORD") }}
        {{- $password = index $secret.data "DB_PASSWORD" }}
      {{- end -}}
    {{- end -}}
    {{- $password }}
{{- end -}}
{{- end -}}


{{- define "database.dbUser" -}}
  {{- if .Values.database.dbUser }}
      {{- .Values.database.dbUser | b64enc -}}
  {{- else -}}
    {{ fail "\n\nERROR:  database.dbUser is empty !!! database dbUser details missing" }}
  {{- end -}}
  {{- if .Values.mariadb.enabled -}}
    {{- if not (eq .Values.database.dbUser .Values.mariadb.db.user)  }}
      {{ fail "\n\nERROR: With mariadb.enabled = true , Set value for mariadb.db.user same as database.dbUser " }}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{- define "database.dbName" -}}
{{- if .Values.database.dbName }}
    {{- .Values.database.dbName -}}
{{- else -}}
  {{ fail "\n\nERROR:  database.dbName is empty !!! database dbName details missing" }}
{{- end -}}
{{- end -}}


{{/*
define "serviceAccount.enabled""
*/}}
{{- define "serviceAccount.enabled" -}}
{{- if or .Values.rbac.create .Values.images.imagePullSecrets .Values.global.cloudbees.imagePullSecrets  -}}
true
{{- end -}}
{{- end -}}

{{- define "os.label" -}}
{{- if (semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion) }}kubernetes.io/os{{- else -}}beta.kubernetes.io/os{{- end -}}
{{- end -}}


{{/*
Define Random Mariadb Credentials
*/}}
{{- define "mariadb.rootPassword" -}}
{{ if .Values.mariadb.enabled }}
{{- $secretName := "mariadb-initdb-secret" }}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
{{- $password := (randAlpha 20) | b64enc }}
{{- if $secret }}
  {{- if (index $secret.data "mariadb-root-password") }}
    {{- $password = index $secret.data "mariadb-root-password" }}
  {{- end -}}
{{- end -}}
{{- $password }}
{{- end -}}
{{- end -}}

{{- define "cloudbees-flow.is-openshift" -}}
{{- if or (.Values.ingress.route ) (.Capabilities.APIVersions.Has "route.openshift.io/v1") -}}
true
{{- end -}}
{{- end -}}

{{- define "cloudbees-flow.serviceAccountName" -}}
{{- if (include "serviceAccount.enabled" .) -}}
{{- .Values.rbac.serviceAccountName | default "cbflow"  -}}
{{- else -}}
{{- .Values.rbac.serviceAccountName | default "default" -}}
{{- end -}}
{{- end -}}


{{- define "cloudbees-flow-ingress.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress" -}}
networking.k8s.io/v1
{{- else -}}
extensions/v1beta1
{{- end -}}
{{- end -}}

{{- define "cloudbees-flow-ingress.backend" -}}
{{- if eq (include "cloudbees-flow-ingress.apiVersion" .) "networking.k8s.io/v1" -}}
service:
  name: flow-web
  port:
    number: 80
{{- else -}}
serviceName: flow-web
servicePort: 80
{{- end -}}
{{- end -}}

{{- define "cloudbees-flow-ingress.pathType" -}}
{{- if eq (include "cloudbees-flow-ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- if (eq .Values.platform "eks") -}}
pathType: ImplementationSpecific
{{- else -}}
pathType: Prefix
{{- end -}}
{{- end -}}
{{- end -}}


{{- define "cloudbees-flow-ingress.annotations" -}}
{{ toYaml .Values.ingress.annotations }}
{{- if and .Values.ingress.class ( or (not (eq (include "cloudbees-flow-ingress.apiVersion" .) "networking.k8s.io/v1")) ( index .Values "nginx-ingress" "enabled" )) }}
kubernetes.io/ingress.class: {{ .Values.ingress.class }}
{{- end }}
{{- if and  ( eq .Values.platform "eks" ) ( eq  .Values.ingress.class "alb" ) }}
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}, {"HTTPS":443}]'
alb.ingress.kubernetes.io/ssl-redirect: '443'
alb.ingress.kubernetes.io/group.name: {{ include "cloudbees-flow.fullname" .}}
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/healthcheck-path: /auth/
{{- end }}
{{- end }}

{{/*
Define DOIS certificates validations
*/}}

{{- define "cloudbees-flow.is-dois-certificate-ca-crt.enabled" -}}
{{- if .Values.dois.certificates.existingSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.dois.certificates.existingSecret ) }}
    {{- if and  $secret (index $secret.data "CBF_DOIS_CA_CRT") }}
       true
    {{- end -}}
{{- else if .Values.dois.certificates.ca.crt }}
true
{{- end }}
{{- end }}

{{- define "cloudbees-flow.is-dois-certificate-ca-key.enabled" -}}
{{- if .Values.dois.certificates.existingSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.dois.certificates.existingSecret ) }}
    {{- if and  $secret (index $secret.data "CBF_DOIS_CA_KEY") }}
       true
    {{- end -}}
{{- else if .Values.dois.certificates.ca.key }}
true
{{- end }}
{{- end }}

{{- define "cloudbees-flow.is-dois-certificate-sign-crt.enabled" -}}
{{- if .Values.dois.certificates.existingSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.dois.certificates.existingSecret ) }}
    {{- if and  $secret (index $secret.data "CBF_DOIS_SIGN_CRT") }}
       true
    {{- end -}}
{{- else if .Values.dois.certificates.sign.crt }}
true
{{- end }}
{{- end }}

{{- define "cloudbees-flow.is-dois-certificate-sign-key.enabled" -}}
{{- if .Values.dois.certificates.existingSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.dois.certificates.existingSecret ) }}
    {{- if and  $secret (index $secret.data "CBF_DOIS_SIGN_KEY") }}
       true
    {{- end -}}
{{- else if .Values.dois.certificates.sign.key }}
true
{{- end }}
{{- end }}

{{- define "cloudbees-flow.is-dois-certificate-node-crt.enabled" -}}
{{- if .Values.dois.certificates.existingSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.dois.certificates.existingSecret ) }}
    {{- if and  $secret (index $secret.data "CBF_DOIS_NODE_CRT") }}
       true
    {{- end -}}
{{- else if .Values.dois.certificates.node.crt }}
true
{{- end }}
{{- end }}

{{- define "cloudbees-flow.is-dois-certificate-node-key.enabled" -}}
{{- if .Values.dois.certificates.existingSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.dois.certificates.existingSecret ) }}
    {{- if and  $secret (index $secret.data "CBF_DOIS_NODE_KEY") }}
       true
    {{- end -}}
{{- else if .Values.dois.certificates.node.key }}
true
{{- end }}
{{- end }}


{{- define "cloudbees-flow.is-dois-certificate-admin-crt.enabled" -}}
{{- if .Values.dois.certificates.existingSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.dois.certificates.existingSecret ) }}
    {{- if and  $secret (index $secret.data "CBF_DOIS_ADMIN_CRT") }}
       true
    {{- end -}}
{{- else if .Values.dois.certificates.admin.crt }}
true
{{- end }}
{{- end }}

{{- define "cloudbees-flow.is-dois-certificate-admin-key.enabled" -}}
{{- if .Values.dois.certificates.existingSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.dois.certificates.existingSecret ) }}
    {{- if and  $secret (index $secret.data "CBF_DOIS_ADMIN_KEY") }}
       true
    {{- end -}}
{{- else if .Values.dois.certificates.admin.key }}
true
{{- end }}
{{- end }}

{{- define "cloudbees-flow.is-dois-certificate-crt-bundle.enabled" -}}
{{- if .Values.dois.certificates.existingSecret }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace .Values.dois.certificates.existingSecret ) }}
    {{- if and  $secret (index $secret.data "CBF_DOIS_CRT_BUNDLE") }}
       true
    {{- end -}}
{{- else if .Values.dois.certificates.bundle }}
true
{{- end }}
{{- end }}

#If dois.replicas is more then 1, then dois will work ONLY in one of the following cases:
# CBF_DOIS_CRT_BUNDLE is defined
# CBF_DOIS_CA_CRT and CBF_DOIS_CA_KEY are defined.
# CBF_DOIS_CA_CRT and CBF_DOIS_SIGN_CRT and CBF_DOIS_SIGN_KEY are defined.
# CBF_DOIS_CA_CRT and CBF_DOIS_SIGN_CRT and CBF_DOIS_NODE_CRT and CBF_DOIS_NODE_KEY and CBF_DOIS_ADMIN_CRT and CBF_DOIS_ADMIN_KEY are defined.

{{- define "validate.dois-certificates" -}}
{{- if gt (float64 (toString (.Values.dois.replicas)))  1.0  -}}
{{- if not ( or ( include "cloudbees-flow.is-dois-certificate-crt-bundle.enabled" . ) ( and ( include "cloudbees-flow.is-dois-certificate-ca-crt.enabled" . ) ( include "cloudbees-flow.is-dois-certificate-ca-key.enabled" . )  ) ( and ( include "cloudbees-flow.is-dois-certificate-ca-crt.enabled" . ) ( include "cloudbees-flow.is-dois-certificate-sign-crt.enabled" . )  ( include "cloudbees-flow.is-dois-certificate-sign-key.enabled" . )  ) ( and ( include "cloudbees-flow.is-dois-certificate-ca-crt.enabled" . ) ( include "cloudbees-flow.is-dois-certificate-sign-crt.enabled" . )  ( include "cloudbees-flow.is-dois-certificate-node-crt.enabled" . ) ( include "cloudbees-flow.is-dois-certificate-node-key.enabled" . ) ( include "cloudbees-flow.is-dois-certificate-admin-crt.enabled" . )  ( include "cloudbees-flow.is-dois-certificate-admin-key.enabled" . ) ) ) -}}
{{ fail "To deploy dois analytics server with more than 1 replica  (dois.certificates) supported set of certificates needs to be defined. Please read installation document or contact cloudbees support for more information." }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "validate.server-hpa" -}}
{{- if and .Values.clusteredMode .Values.server.autoscaling.enabled -}}
{{- if gt (float64 (toString (.Values.server.replicas)))  (float64 (toString (.Values.server.autoscaling.minReplicas)))  -}}
{{ fail "To enable HPA please make sure server.autoscaling.minReplicas is equal to server.replicas  " }}
{{- end -}}
{{- if gt (float64 (toString (.Values.server.replicas)))  (float64 (toString (.Values.server.autoscaling.maxReplicas)))  -}}
{{ fail "To enable HPA please make sure server.autoscaling.maxReplicas should be greater than equal to server.replicas " }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "validate.web-hpa" -}}
{{- if .Values.web.autoscaling.enabled -}}
{{- if gt (float64 (toString (.Values.web.replicas)))  (float64 (toString (.Values.web.autoscaling.minReplicas)))  -}}
{{ fail "To enable HPA please make sure web.autoscaling.minReplicas is equal to web.replicas  " }}
{{- end -}}
{{- if gt (float64 (toString (.Values.web.replicas)))  (float64 (toString (.Values.web.autoscaling.maxReplicas)))  -}}
{{ fail "To enable HPA please make sure web.autoscaling.maxReplicas should be greater than equal to web.replicas " }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "validate.repository-hpa" -}}
{{- if .Values.repository.autoscaling.enabled -}}
{{- if gt (float64 (toString (.Values.repository.replicas)))  (float64 (toString (.Values.repository.autoscaling.minReplicas)))  -}}
{{ fail "To enable HPA please make sure repository.autoscaling.minReplicas is equal to repository.replicas  " }}
{{- end -}}
{{- if gt (float64 (toString (.Values.repository.replicas)))  (float64 (toString (.Values.repository.autoscaling.maxReplicas)))  -}}
{{ fail "To enable HPA please make sure repository.autoscaling.maxReplicas should be greater than equal to repository.replicas " }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate additionalVolumes and additionalVolumeMounts arrays have same size
Validate each item of additionalVolumes and additionalVolumeMounts arrays has "name" value
Validate each additionalVolume item name has same item name in additionalVolumeMounts
Validate each additionalVolumeMounts item name has same item name in additionalVolume
*/}}
{{- define "validate.additionalVolumes-and-additionalVolumeMounts" -}}
{{ $addVol := list .additionalVolumes }}
{{ $addVolMnt := list .additionalVolumeMounts }}

{{- if ne ( len (index $addVol 0) ) (len (index $addVolMnt 0 ))  -}}
{{ fail " Make sure all additionalVolumes has equal number of corresponded additionalVolumeMounts   " }}
{{- end -}}

{{ range $keyAddVol, $valAddVol := .additionalVolumes }}
{{ if not ($valAddVol.name) }}
{{ fail "Additional Volumes Items should have \"name\" field and it shouldn't be empty" }}
{{ end }}
{{ end }}

{{ range $keyAddVol, $valAddVolMnt := .additionalVolumeMounts }}
{{ if not ($valAddVolMnt.name) }}
{{ fail "Additional Volume Mounts Items should have \"name\" field and it shouldn't be empty" }}
{{ end }}
{{ end }}


{{ $addVolNames := list }}
{{ range $keyAddVol, $valAddVol := .additionalVolumes }}
{{ $addVolNames = append $addVolNames ( list $valAddVol.name ) }}
{{ end }}
{{ $addVolMntNames := list }}
{{ range $keyAddVol, $valAddVol := .additionalVolumeMounts }}
{{ $addVolMntNames = append $addVolMntNames ( list $valAddVol.name ) }}
{{ end }}

{{ range $volName := $addVolNames }}
{{- if not (has $volName $addVolMntNames)  -}}
{{ fail  " Make sure all additionalVolumes names has corresponded name value in additionalVolumeMount  " }}
{{- end -}}
{{- end -}}

{{ range $volMntName := $addVolMntNames }}
{{- if not (has $volMntName $addVolNames)  -}}
{{ fail  " Make sure all additionalVolumeMount names has corresponded name value in additionalVolumes " }}
{{- end -}}
{{- end -}}

{{- end }}

{{- define "cloudbees-flow-hpa.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" -}}
autoscaling/v2
{{- else -}}
autoscaling/v2beta2
{{- end -}}
{{- end -}}

{{- define "validate.boundAgent-existingSecret" -}}
{{- if and .Values.flowCredentials.existingSecret .Values.boundAgent.flowCredentials.serverSecretReference -}}
{{- if not .Values.boundAgent.flowCredentials.existingSecret  -}}
{{ fail "To use flowCredentials.existingSecret please set boundAgent.flowCredentials.existingSecret same value as flowCredentials.existingSecret in your values file " }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "validate-bound-agent-volume-permission.openshift" -}}
{{- if and (.Capabilities.APIVersions.Has "route.openshift.io/v1") (.Values.boundAgent.volumePermissions.enabled) -}}
{{ fail "Please make boundAgent.volumePermissions.enabled=false  to install/upgrade on OpenShift platform " }}
{{- end -}}
{{- end -}}
