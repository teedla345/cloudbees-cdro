{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cloudbees-flow-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cloudbees-flow-agent.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name (.Values.releaseNamePrefix | default .Release.Name) -}}
{{- ( .Values.releaseNamePrefix | default .Release.Name ) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" ( .Values.releaseNamePrefix | default .Release.Name ) $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cloudbees-flow-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "cloudbees-flow-agent.labels" -}}
app.kubernetes.io/name: {{ include "cloudbees-flow-agent.name" . }}
helm.sh/chart: {{ include "cloudbees-flow-agent.chart" . }}
app.kubernetes.io/instance: {{ .Values.releaseNamePrefix | default .Release.Name  }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

`
{{/*
Agents hostnames compiled with space delimiter
*/}}
{{- define "cloudbees-flow-agent.hostnames" -}}
{{- $count := .Values.replicas | int -}}
{{- $hosts := dict "names" (list) -}}
{{- range $i, $e := until $count}}
{{- $noop := printf "%s-flow-agent-%d.%s-flow-agents.%s.svc.cluster.local" $.Release.Name $i $.Release.Name $.Release.Namespace| append $hosts.names | set $hosts "names" -}}
{{- end -}}
{{- join " " $hosts.names -}}
{{- end -}}

{{/*
Processing templates in the resource name value
*/}}
{{- define "cloudbees-flow-agent.resourcename" -}}
{{- tpl (regexReplaceAll "\\{\\{\\s*(hostname|ordinalIndex)\\s*\\}\\}" .Values.resourceName "^@${1}@^") . -}}
{{- end -}}

{{/*
Processing templates in the resource name value for NOTES.txt
*/}}
{{- define "cloudbees-flow-agent.resourcename.notes" -}}
{{- tpl (regexReplaceAll "\\{\\{\\s*(hostname|ordinalIndex)\\s*\\}\\}" .Values.resourceName "<${1}>") . -}}
{{- end -}}

{{/*
define "serviceAccount.enabled""
*/}}
{{- define "serviceAccount.enabled" -}}
{{- if or .Values.images.imagePullSecrets .Values.rbac.create -}}
true
{{- end -}}
{{- if .Values.global -}}
{{- if .Values.global.cloudbees.imagePullSecrets -}}
true
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "cloudbees-flow-agent.serviceAccountName" -}}
{{- if (include "serviceAccount.enabled" .) -}}
{{- .Values.rbac.serviceAccountName | default (printf "%s-%s" (.Values.releaseNamePrefix | default .Release.Name )  "cbagent")  -}}
{{- else -}}
{{- .Values.rbac.serviceAccountName | default "default" -}}
{{- end -}}
{{- end -}}

{{- define "cloudbees-flow-agent-hpa.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" -}}
autoscaling/v2
{{- else -}}
autoscaling/v2beta2
{{- end -}}
{{- end -}}
