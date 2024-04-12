/*
Copyright 2023.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// EDIT THIS FILE!  THIS IS SCAFFOLDING FOR YOU TO OWN!
// NOTE: json tags are required.  Any new fields you add must have json tags for the fields to be serialized.

// HealthCheckSpec defines the desired state of HealthCheck
type HealthCheckSpec struct {
	// INSERT ADDITIONAL SPEC FIELDS - desired state of cluster
	// Important: Run "make" to regenerate code after modifying this file

	// CheckName is the name of the health check
	CheckName string `json:"checkName,omitempty"`
	// ExpectedStatusCode is the expected HTTP status code
	ExpectedStatusCode int `json:"expectedStatusCode,omitempty"`
	// Interval is the time interval between health checks
	Interval int `json:"interval,omitempty"`
	// IsPaused indicates whether the health check is paused
	IsPaused bool `json:"isPaused,omitempty"`
	// Retries is the number of retries in case of failure
	Retries int `json:"retries,omitempty"`
	// Uri is the URI to be checked
	Uri string `json:"uri,omitempty"`
	// SSL defines whether https must be used
	SSL bool `json:"ssl,omitempty"`
}

// HealthCheckStatus defines the observed state of HealthCheck
type HealthCheckStatus struct {
	// INSERT ADDITIONAL STATUS FIELD - define observed state of cluster
	// Important: Run "make" to regenerate code after modifying this file
	// Last Execution Time of the CronJob
	LastExecutionTime *metav1.Time `json:"lastExecutionTime,omitempty" protobuf:"bytes,4,opt,name=lastExecutionTime"`
	// Status of the CronJob
	CronJobSuspended bool `json:"cronJobSuspended"`
	ActiveJobs       int  `json:"activeJobs"`
}

//+kubebuilder:object:root=true
//+kubebuilder:subresource:status
// +kubebuilder:resource:scope=Namespaced
//+kubebuilder:resource:shortName=hc

// HealthCheck is the Schema for the healthchecks API
type HealthCheck struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec   HealthCheckSpec   `json:"spec,omitempty"`
	Status HealthCheckStatus `json:"status,omitempty"`
}

//+kubebuilder:object:root=true

// HealthCheckList contains a list of HealthCheck
type HealthCheckList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`
	Items           []HealthCheck `json:"items"`
}

func init() {
	SchemeBuilder.Register(&HealthCheck{}, &HealthCheckList{})
}
