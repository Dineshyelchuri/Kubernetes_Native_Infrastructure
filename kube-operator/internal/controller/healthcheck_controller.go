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

package controller

import (
	"context"
	"fmt"
	"reflect"
	"time"

	"github.com/go-logr/logr"
	batchv1 "k8s.io/api/batch/v1"
	kubev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/types"
	"k8s.io/client-go/tools/record"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"
	"sigs.k8s.io/controller-runtime/pkg/log"

	webappv1 "github.com/cyse7125-fall2023-group06/kube-operator/api/v1"
)

var finalizer = "webapp.kube.hellodocker.com/finalizer"

// HealthCheckReconciler reconciles a HealthCheck object
type HealthCheckReconciler struct {
	client.Client
	Log           logr.Logger
	Scheme        *runtime.Scheme
	EventRecorder record.EventRecorder
}

//+kubebuilder:rbac:namespace=kube-operator-system,groups=webapp.kube.hellodocker.com,resources=healthchecks,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:namespace=kube-operator-system,groups=webapp.kube.hellodocker.com,resources=healthchecks/status,verbs=get;update;patch
//+kubebuilder:rbac:namespace=kube-operator-system,groups=webapp.kube.hellodocker.com,resources=healthchecks/finalizers,verbs=update
//+kubebuilder:rbac:namespace=kube-operator-system,groups=batch,resources=cronjobs,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:namespace=kube-operator-system,groups=batch,resources=cronjobs/status,verbs=get;update;patch
//+kubebuilder:rbac:namespace=kube-operator-system,groups="",resources=configmaps,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:namespace=kube-operator-system,groups="",resources=configmaps/status,verbs=get;update;patch

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the HealthCheck object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.16.3/pkg/reconcile
func (r *HealthCheckReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	_ = log.FromContext(ctx)

	// TODO(user): your logic here

	_ = r.Log.WithValues("healthcheck", req.NamespacedName)

	// Fetch the HealthCheck instance
	healthCheck := &webappv1.HealthCheck{}
	err := r.Get(ctx, req.NamespacedName, healthCheck)

	if err != nil {
		if errors.IsNotFound(err) {
			// Object not found, likely deleted, clean up any resources
			return ctrl.Result{}, nil
		}
		// Error fetching HealthCheck, return with error
		return ctrl.Result{}, err
	}
	// Check for deletion
	if healthCheck.ObjectMeta.DeletionTimestamp.IsZero() {
		// HealthCheck is not being deleted, reconcile logic here
		// Check if the finalizer is present, if not, add it
		if !controllerutil.ContainsFinalizer(healthCheck, finalizer) {
			controllerutil.AddFinalizer(healthCheck, finalizer)
			if err := r.Update(ctx, healthCheck); err != nil {
				return ctrl.Result{}, err
			}
		}

		// Reconcile logic for creating, updating, or deleting CronJob
		if err := r.reconcileCronJob(ctx, healthCheck); err != nil {
			// r.EventRecorder.Event(healthCheck, kubev1.EventTypeWarning, "Reconciliation Failed", "Failed to create CronJob")

			if errors.IsConflict(err) {
				// Retry the reconciliation since there was a conflict
				return ctrl.Result{Requeue: true}, nil
			}
			return ctrl.Result{}, err
		}
	} else {
		// HealthCheck is being deleted, cleanup logic here
		if controllerutil.ContainsFinalizer(healthCheck, finalizer) {
			if err := r.deleteExternalResources(ctx, healthCheck); err != nil {
				r.EventRecorder.Event(healthCheck, kubev1.EventTypeWarning, "Cleanup Failed", "Failed to clean up resources during deletion")
				return ctrl.Result{}, err
			}
			controllerutil.RemoveFinalizer(healthCheck, finalizer)
			if err := r.Update(ctx, healthCheck); err != nil {
				r.EventRecorder.Event(healthCheck, kubev1.EventTypeWarning, "Finalizer Removal Failed", "Failed to remove finalizer during deletion")
				return ctrl.Result{}, err
			}
		}
		return ctrl.Result{}, nil
	}

	return ctrl.Result{}, nil
}

// SetupWithManager sets up the controller with the Manager.
func (r *HealthCheckReconciler) SetupWithManager(mgr ctrl.Manager) error {
	r.EventRecorder = mgr.GetEventRecorderFor("healthcheck-controller")

	return ctrl.NewControllerManagedBy(mgr).
		For(&webappv1.HealthCheck{}).
		Owns(&batchv1.CronJob{}).
		Complete(r)
}

func (r *HealthCheckReconciler) reconcileCronJob(ctx context.Context, hc *webappv1.HealthCheck) error {
	// Your logic to create or update CronJob based on HealthCheck

	// Set the image URI, expected status code, check name, and other environment variables
	// envVars := []kubev1.EnvVar{
	// 	{Name: "URI", Value: hc.Spec.Uri},
	// 	{Name: "EXPECTED_STATUS_CODE", Value: fmt.Sprintf("%d", hc.Spec.ExpectedStatusCode)},
	// 	{Name: "CHECK_NAME", Value: hc.Spec.CheckName},
	// }

	// Create or update the ConfigMap with health check configuration
	configMap := &kubev1.ConfigMap{
		ObjectMeta: metav1.ObjectMeta{
			Name:      hc.Name + "-configmap",
			Namespace: hc.Namespace,
		},
		Data: map[string]string{
			"URI":                  hc.Spec.Uri,
			"EXPECTED_STATUS_CODE": fmt.Sprintf("%d", hc.Spec.ExpectedStatusCode),
			"CHECK_NAME":           hc.Spec.CheckName,
			"SSL":                  fmt.Sprintf("%t", hc.Spec.SSL),
		},
	}

	// Set owner reference for the ConfigMap
	if err := controllerutil.SetControllerReference(hc, configMap, r.Scheme); err != nil {
		return err
	}

	existingConfigMap := &kubev1.ConfigMap{}
	cm := r.Get(ctx, types.NamespacedName{Name: hc.Name + "-configmap", Namespace: hc.Namespace}, existingConfigMap)
	if cm != nil && !errors.IsNotFound(cm) {
		return cm
	}

	if errors.IsNotFound(cm) {
		// ConfigMap does not exist, create it
		if err := r.Create(ctx, configMap); err != nil {
			r.EventRecorder.Event(hc, kubev1.EventTypeWarning, "ConfigMapCreationFailed", fmt.Sprintf("Failed to create ConfigMap for %s", hc.Name))
			return err
		}
		r.EventRecorder.Event(hc, kubev1.EventTypeNormal, "ConfigMapCreated", fmt.Sprintf("ConfigMap created for %s", hc.Name))
	} else {
		// ConfigMap already exists, update its data
		// existingConfigMap.Data = configMap.Data
		// if err := r.Update(ctx, existingConfigMap); err != nil {
		// 	r.EventRecorder.Event(hc, kubev1.EventTypeWarning, "ConfigMapUpdateFailed", fmt.Sprintf("Failed to update ConfigMap for %s", hc.Name))
		// 	return err
		// }
		// r.EventRecorder.Event(hc, kubev1.EventTypeNormal, "ConfigMapUpdated", fmt.Sprintf("ConfigMap updated for %s", hc.Name))

		if !reflect.DeepEqual(existingConfigMap.Data, configMap.Data) {
			existingConfigMap.Data = configMap.Data
			if err := r.Update(ctx, existingConfigMap); err != nil {
				r.EventRecorder.Event(hc, kubev1.EventTypeWarning, "ConfigMapUpdateFailed", fmt.Sprintf("Failed to update ConfigMap for %s", hc.Name))
				return err
			}
			r.EventRecorder.Event(hc, kubev1.EventTypeNormal, "ConfigMapUpdated", fmt.Sprintf("ConfigMap updated for %s", hc.Name))
		}
	}

	// Set the CronJob schedule based on the interval in seconds
	interval := time.Duration(hc.Spec.Interval) * time.Second
	schedule := fmt.Sprintf("*/%d * * * *", int(interval.Seconds())) // Run every specified seconds

	// Set backoff limit based on retries
	backoffLimit := int32(hc.Spec.Retries)

	// Set the suspend flag based on isPaused
	suspend := hc.Spec.IsPaused

	// Create or update the CronJob with the same name as the CR
	cronJob := &batchv1.CronJob{
		ObjectMeta: metav1.ObjectMeta{
			Name:      hc.Name, // Use the same name as the CR
			Namespace: hc.Namespace,
		},
		Spec: batchv1.CronJobSpec{
			Schedule:          schedule,
			JobTemplate:       batchv1.JobTemplateSpec{},
			ConcurrencyPolicy: batchv1.AllowConcurrent,
			Suspend:           &suspend,
		},
	}

	shareProcess := true

	// Set the Job template
	cronJob.Spec.JobTemplate.Spec.Template.Spec = kubev1.PodSpec{
		Containers: []kubev1.Container{
			{
				Name:  "healthcheck-container",
				Image: "quay.io/csye7125ruth/kafka-producer:latest",
				// Env:   envVars,
			},
		},
		RestartPolicy:         kubev1.RestartPolicyNever,
		ShareProcessNamespace: &shareProcess,
		ImagePullSecrets: []kubev1.LocalObjectReference{
			{
				Name: "reg-cred",
			},
		},
	}

	// Set backoff limit
	if backoffLimit > 0 {
		cronJob.Spec.JobTemplate.Spec.BackoffLimit = &backoffLimit
	}

	// Set owner reference
	if err := controllerutil.SetControllerReference(hc, cronJob, r.Scheme); err != nil {
		return err
	}

	// Attach the ConfigMap to the PodSpec as environment variables
	cronJob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].EnvFrom = []kubev1.EnvFromSource{
		{
			ConfigMapRef: &kubev1.ConfigMapEnvSource{
				LocalObjectReference: kubev1.LocalObjectReference{Name: configMap.Name},
			},
		},
	}

	cronJob.Spec.JobTemplate.Spec.Template.Spec.Containers[0].Env = []kubev1.EnvVar{
		{
			Name: "KAFKA_SERVER",
			ValueFrom: &kubev1.EnvVarSource{
				ConfigMapKeyRef: &kubev1.ConfigMapKeySelector{
					LocalObjectReference: kubev1.LocalObjectReference{Name: "kube-operator-kafka-cm"},
					Key:                  "KAFKA_SERVER",
				},
			},
		},
		{
			Name: "KAFKA_USER",
			ValueFrom: &kubev1.EnvVarSource{
				ConfigMapKeyRef: &kubev1.ConfigMapKeySelector{
					LocalObjectReference: kubev1.LocalObjectReference{Name: "kube-operator-kafka-cm"},
					Key:                  "KAFKA_USER",
				},
			},
		},
		{
			Name: "KAFKA_PASSWORD",
			ValueFrom: &kubev1.EnvVarSource{
				SecretKeyRef: &kubev1.SecretKeySelector{
					LocalObjectReference: kubev1.LocalObjectReference{Name: "kafka-user-passwords"},
					Key:                  "client-passwords",
				},
			},
		},
	}

	// Check if the CronJob already exists
	foundCronJob := &batchv1.CronJob{}
	err := r.Get(ctx, types.NamespacedName{Name: hc.Name, Namespace: hc.Namespace}, foundCronJob)
	if err != nil && client.IgnoreNotFound(err) != nil {
		return err
	}

	if errors.IsNotFound(err) {
		// CronJob does not exist, create it
		if err := r.Create(ctx, cronJob); err != nil {
			r.EventRecorder.Event(hc, kubev1.EventTypeWarning, "CronJobCreationFailed", fmt.Sprintf("Failed to create CronJob for %s", hc.Name))
			return err
		}
		r.EventRecorder.Event(hc, kubev1.EventTypeNormal, "CronJobCreated", fmt.Sprintf("CronJob created for %s", hc.Name))
	} else {
		// CronJob already exists, update it
		// foundCronJob.Spec = cronJob.Spec
		// if err := r.Update(ctx, foundCronJob); err != nil {
		// 	r.EventRecorder.Event(hc, kubev1.EventTypeWarning, "CronJobUpdationFailed", fmt.Sprintf("Failed to update CronJob for %s", hc.Name))
		// 	return err
		// }
		// r.EventRecorder.Event(hc, kubev1.EventTypeNormal, "CronJobUpdated", fmt.Sprintf("CronJob updated for %s", hc.Name))

		if !reflect.DeepEqual(foundCronJob.Spec.Schedule, cronJob.Spec.Schedule) ||
			!reflect.DeepEqual(foundCronJob.Spec.Suspend, cronJob.Spec.Suspend) {
			foundCronJob.Spec = cronJob.Spec
			if err := r.Update(ctx, foundCronJob); err != nil {
				r.EventRecorder.Event(hc, kubev1.EventTypeWarning, "CronJobUpdationFailed", fmt.Sprintf("Failed to update CronJob for %s", hc.Name))
				return err
			}
			r.EventRecorder.Event(hc, kubev1.EventTypeNormal, "CronJobUpdated", fmt.Sprintf("CronJob updated for %s", hc.Name))
		}
	}

	hc.Status.LastExecutionTime = foundCronJob.Status.LastScheduleTime
	if foundCronJob.Spec.Suspend != nil {
		hc.Status.CronJobSuspended = *foundCronJob.Spec.Suspend
	} else {
		hc.Status.CronJobSuspended = false
	}
	hc.Status.ActiveJobs = len(foundCronJob.Status.Active)

	// Update HealthCheck status in the cluster
	if err := r.Status().Update(ctx, hc); err != nil {
		return err
	}

	return nil
}

// deleteExternalResources is a placeholder for cleanup logic when HealthCheck is being deleted.
func (r *HealthCheckReconciler) deleteExternalResources(ctx context.Context, hc *webappv1.HealthCheck) error {
	// Delete the associated CronJob
	cronJob := &batchv1.CronJob{
		ObjectMeta: metav1.ObjectMeta{
			Name:      hc.Name,
			Namespace: hc.Namespace,
		},
	}
	if err := r.Delete(ctx, cronJob); err != nil && !errors.IsNotFound(err) {
		// Return the error if it's not a "not found" error
		return err
	}

	r.EventRecorder.Event(hc, kubev1.EventTypeNormal, "CronJobDeleted", fmt.Sprintf("CronJob deleted for %s", hc.Name))

	// Delete the associated ConfigMap
	configMap := &kubev1.ConfigMap{
		ObjectMeta: metav1.ObjectMeta{
			Name:      hc.Name + "-configmap",
			Namespace: hc.Namespace,
		},
	}
	if err := r.Delete(ctx, configMap); err != nil && !errors.IsNotFound(err) {
		return err
	}

	r.EventRecorder.Event(hc, kubev1.EventTypeNormal, "ConfigMapDeleted", fmt.Sprintf("ConfigMap deleted for %s", hc.Name))

	return nil
}
