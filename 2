-                       ingressAnnotations: map[string]string{
-                               "annotator.ingress.kubernetes.io/reconcile": "true",
+                       name:       "AddDefaultAnnotations_WhenIngressExistsWithoutAnnotations",
+                       wantResult: ctrl.Result{},
+                       wantAnnotations: map[string]string{
+                               "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
+                               "new-key": "new-value",
                        },
-                       wantResult: ctrl.Result{Requeue: true},
                },
                {
-                       name:       "ReconcileAnnotationTrueWithUpdateError_ShouldReturnError",
-                       clientOpts: &fakeclient.ClientOpts{UpdateError: true},
+                       name: "ReconcileAnnotations_WhenReconcileAnnotationIsTrue",
                        ingressAnnotations: map[string]string{
                                "annotator.ingress.kubernetes.io/reconcile": "true",
                        },
                        wantResult: ctrl.Result{},
                        wantAnnotations: map[string]string{
-                               "annotator.ingress.kubernetes.io/reconcile": "true",
+                               "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
+                               "new-key": "new-value",
                        },
-                       wantError: "mocked UpdateError",
                },
                {
-                       name: "ReconcileAnnotationTrueWithExtraAnnotations_ShouldRequeueAndRetainAnnotations",
-                       ingressAnnotations: map[string]string{
-                               "annotator.ingress.kubernetes.io/reconcile": "true",
-                               "example-key": "example-value",
-                       },
-                       wantResult: ctrl.Result{Requeue: true},
+                       name:               "AddNewAnnotations_WhenValidIngressHasNoMatchingRule",
+                       ingressAnnotations: map[string]string{},
+                       wantResult:         ctrl.Result{},
                        wantAnnotations: map[string]string{
-                               "example-key": "example-value",
+                               "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
+                               "new-key": "new-value",
                        },
                },
                {
-                       name: "ValidIngressWithExampleAnnotation_ShouldRetainAnnotation",
+                       name: "RetainExistingAnnotations_WhenValidIngressHasPreExistingAnnotations",
                        ingressAnnotations: map[string]string{
-                               "example-key": "example-value",
+                               "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
+                               "new-key": "new-value",
                        },
                        wantResult: ctrl.Result{},
                        wantAnnotations: map[string]string{
-                               "example-key": "example-value",
+                               "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
+                               "new-key": "new-value",
                        },
                },
                {
-                       name: "InvalidManagedAnnotationsWithNamespace_ShouldResetInvalidAnnotations",
+                       name: "ReturnEarly_WhenNoAnnotationChangesAreDetected",
                        ingressAnnotations: map[string]string{
-                               "annotator.ingress.kubernetes.io/managed-annotations": "invalid-json",
-                               "example-key": "example-value",
+                               "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
+                               "new-key": "old-value",
                        },
                        wantResult: ctrl.Result{},
                        wantAnnotations: map[string]string{
-                               "example-key": "example-value",
+                               "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
+                               "new-key": "new-value",
                        },
                },
                {
-                       name: "ValidIngressWithoutMatchingRule_ShouldAddNewAnnotations",
+                       name: "ReconcileAnnotations_WithExtraAnnotationsAndReconcileTrue",
                        ingressAnnotations: map[string]string{
-                               "annotator.ingress.kubernetes.io/rules": "rule1",
+                               "annotator.ingress.kubernetes.io/reconcile": "true",
+                               "example-key": "example-value",
                        },
                        wantResult: ctrl.Result{},
                        wantAnnotations: map[string]string{
                                "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
-                               "annotator.ingress.kubernetes.io/rules":               "rule1",
-                               "new-key":                                             "new-value",
+                               "example-key": "example-value",
+                               "new-key":     "new-value",
                        },
                },
                {
-                       name: "ValidIngressWithMatchingRule_ShouldAddNewAnnotations",
+                       name: "RetainExistingAnnotations_WhenIngressHasExampleAnnotation",
                        ingressAnnotations: map[string]string{
-                               "annotator.ingress.kubernetes.io/rules": "rule1",
+                               "example-key": "example-value",
                        },
                        wantResult: ctrl.Result{},
                        wantAnnotations: map[string]string{
                                "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
-                               "annotator.ingress.kubernetes.io/rules":               "rule1",
-                               "new-key":                                             "new-value",
+                               "example-key": "example-value",
+                               "new-key":     "new-value",
                        },
                },
                {
-                       name: "ValidIngressWithPreExistingAnnotations_ShouldRetainExistingAnnotations",
+                       name: "ResetInvalidManagedAnnotations_WhenInvalidJSONIsPresent",
                        ingressAnnotations: map[string]string{
-                               "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
-                               "annotator.ingress.kubernetes.io/rules":               "rule1",
-                               "new-key":                                             "new-value",
+                               "annotator.ingress.kubernetes.io/managed-annotations": "invalid-json",
+                               "example-key": "example-value",
                        },
                        wantResult: ctrl.Result{},
                        wantAnnotations: map[string]string{
                                "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
-                               "annotator.ingress.kubernetes.io/rules":               "rule1",
-                               "new-key":                                             "new-value",
+                               "example-key": "example-value",
+                               "new-key":     "new-value",
                        },
                },
+       }
+
+       for i, tc := range testCases {
+               t.Run(testcase.Name(i, tc.name), func(t *testing.T) {
+                       ctx := context.Background()
+                       nn := types.NamespacedName{Namespace: "default", Name: "my-ingress"}
+
+                       namespace := &corev1.Namespace{ObjectMeta: ctrl.ObjectMeta{Name: "default"}}
+                       ingress := &networkingv1.Ingress{
+                               ObjectMeta: ctrl.ObjectMeta{
+                                       Namespace:         "default",
+                                       Name:              "my-ingress",
+                                       Annotations:       tc.ingressAnnotations,
+                                       DeletionTimestamp: tc.deletionTimestamp,
+                                       Finalizers:        tc.finalizers,
+                               },
+                       }
+                       client := fakeclient.NewClient(tc.clientOpts, namespace, ingress)
+
+                       // Mock the rules store
+                       rules := []model.Rule{{
+                               Selector:    model.Selector{Include: "*"},
+                               Description: "new-key-value",
+                               Annotations: model.Annotations{"new-key": "new-value"},
+                       }}
+                       store := mocks.NewMockIRulesStore(mockCtrl)
+                       store.EXPECT().GetRules().Return(rules).AnyTimes()
+
+                       reconciler := &IngressReconciler{
+                               Client:  client,
+                               Matcher: matcher.New(store),
+                       }
+
+                       // Run the Reconcile method
+                       got, err := reconciler.Reconcile(ctx, ctrl.Request{NamespacedName: nn})
+
+                       assert.Equal(t, tc.wantResult, got)
+                       assert.NoError(t, err)
+
+                       updatedIngress := &networkingv1.Ingress{}
+                       err = client.Get(ctx, nn, updatedIngress)
+                       assert.NoError(t, err)
+                       assert.Equal(t, tc.wantAnnotations, updatedIngress.Annotations)
+               })
+       }
+}
+
+func TestReconcile_error(t *testing.T) {
+       mockCtrl := gomock.NewController(t)
+       defer mockCtrl.Finish()
+
+       testCases := []struct {
+               name               string
+               clientOpts         *fakeclient.ClientOpts
+               requestNN          *types.NamespacedName
+               ingressAnnotations map[string]string
+               deletionTimestamp  *metav1.Time
+               finalizers         []string
+               wantResult         ctrl.Result
+               wantAnnotations    map[string]string
+               wantError          string
+               wantGetError       string
+       }{
                {
-                       name: "ValidIngressWithUnmatchingRule_ShouldRetainExistingAnnotations",
-                       ingressAnnotations: map[string]string{
-                               "annotator.ingress.kubernetes.io/rules": "xxx",
-                       },
-                       wantResult: ctrl.Result{},
-                       wantAnnotations: map[string]string{
-                               "annotator.ingress.kubernetes.io/rules": "xxx",
-                       },
+                       name:         "IngressDoesNotExist_ShouldReturnNotFoundError",
+                       requestNN:    &types.NamespacedName{Namespace: "default", Name: "xxx"},
+                       wantResult:   ctrl.Result{},
+                       wantGetError: `ingresses.networking.k8s.io "xxx" not found`,
                },
                {
-                       name: "NoChangesDetected_ShouldReturnEarlyWithoutUpdates",
+                       name:       "ReconcileAnnotationTrueWithUpdateError_ShouldReturnError",
+                       clientOpts: &fakeclient.ClientOpts{UpdateError: true},
                        ingressAnnotations: map[string]string{
-                               "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
-                               "annotator.ingress.kubernetes.io/rules":               "rule1",
-                               "new-key":                                             "old-value",
+                               "annotator.ingress.kubernetes.io/reconcile": "true",
                        },
-                       wantResult: ctrl.Result{},
+                       wantResult: ctrl.Result{RequeueAfter: 30 * time.Second},
                        wantAnnotations: map[string]string{
-                               "annotator.ingress.kubernetes.io/managed-annotations": "{\"new-key\":\"new-value\"}\n",
-                               "annotator.ingress.kubernetes.io/rules":               "rule1",
-                               "new-key":                                             "new-value",
+                               "annotator.ingress.kubernetes.io/reconcile": "true",
                        },
+                       wantError: "mocked UpdateError",
                },
                {
                        name:       "ClientGetError_ShouldReturnError",
@@ -239,13 +286,17 @@ func TestIngressReconciler_Reconcile(t *testing.T) {
                        client := fakeclient.NewClient(tc.clientOpts, namespace, ingress)

                        // Mock the rules store
-                       rules := &model.Rules{"rule1": {"new-key": "new-value"}}
+                       rules := []model.Rule{{
+                               Selector:    model.Selector{Include: "*"},
+                               Description: "rule1",
+                               Annotations: model.Annotations{"new-key": "new-value"},
+                       }}
                        store := mocks.NewMockIRulesStore(mockCtrl)
                        store.EXPECT().GetRules().Return(rules).AnyTimes()

                        reconciler := &IngressReconciler{
-                               Client:     client,
-                               RulesStore: store,
+                               Client:  client,
+                               Matcher: matcher.New(store),
                        }

                        // Run the Reconcile method
@@ -272,6 +323,58 @@ func TestIngressReconciler_Reconcile(t *testing.T) {
        }
 }

+func TestGetToBeAnnotations(t *testing.T) {
+       ctx := context.TODO()
+
+       // Mock inputs
+       namespace := &corev1.Namespace{ObjectMeta: ctrl.ObjectMeta{Name: "default"}}
+       ingress := &networkingv1.Ingress{
+               ObjectMeta: ctrl.ObjectMeta{
+                       Namespace: "default",
+                       Name:      "my-ingress",
+                       Annotations: model.Annotations{
+                               "key1":                      "value1",
+                               model.ReconcileKey:          "true",
+                               model.ManagedAnnotationsKey: `{"managed-key": "managed-value"}`,
+                       },
+               },
+       }
+
+       mockCtrl := gomock.NewController(t)
+       defer mockCtrl.Finish()
+
+       rules := []model.Rule{{
+               Selector:    model.Selector{Include: "*"},
+               Description: "rule1",
+               Annotations: model.Annotations{"new-key": "new-value"},
+       }}
+       store := mocks.NewMockIRulesStore(mockCtrl)
+       store.EXPECT().GetRules().Return(rules).AnyTimes()
+
+       client := fakeclient.NewClient(nil, namespace, ingress)
+       reconciler := &IngressReconciler{
+               Client:  client,
+               Matcher: matcher.New(store),
+       }
+       // Execute
+       scope := &ingressScope{
+               logger:    logr.Logger{},
+               namespace: namespace,
+               ingress:   ingress,
+       }
+       result := reconciler.GetToBeAnnotations(ctx, scope)
+
+       // Expected annotations
+       expected := model.Annotations{
+               "key1":                      "value1",
+               "new-key":                   "new-value",
+               model.ManagedAnnotationsKey: "{\"new-key\":\"new-value\"}\n",
+       }
+
+       // Validate
+       assert.Equal(t, expected, result)
+}
+
 func TestCopyAnnotations(t *testing.T) {
        tests := []struct {
                name           string
@@ -335,140 +438,3 @@ func TestCopyAnnotations(t *testing.T) {
                })
        }
 }
-
-func TestGetRuleNamesFromObject(t *testing.T) {
-       testCases := []struct {
-               name          string
-               namespace     *corev1.Namespace
-               key           string
-               wantRuleNames []string
-       }{
-               {
-                       name: "should return ruleNames when annotation exists",
-                       namespace: &corev1.Namespace{
-                               ObjectMeta: metav1.ObjectMeta{
-                                       Name: "example-namespace",
-                                       Annotations: map[string]string{
-                                               model.RulesKey: "rule2,rule1,rule3",
-                                       },
-                               },
-                       },
-                       key:           model.RulesKey,
-                       wantRuleNames: []string{"rule2", "rule1", "rule3"},
-               },
-               {
-                       name: "should return ruleNames when annotation exists",
-                       namespace: &corev1.Namespace{
-                               ObjectMeta: metav1.ObjectMeta{
-                                       Name: "example-namespace",
-                                       Annotations: map[string]string{
-                                               model.RulesKey: "rule2, rule1, rule3",
-                                       },
-                               },
-                       },
-                       key:           model.RulesKey,
-                       wantRuleNames: []string{"rule2", "rule1", "rule3"},
-               },
-               {
-                       name: "should return empty slice when annotations is nil",
-                       namespace: &corev1.Namespace{
-                               ObjectMeta: metav1.ObjectMeta{
-                                       Name:        "example-namespace",
-                                       Annotations: nil,
-                               },
-                       },
-                       key:           "nonExistentKey",
-                       wantRuleNames: []string{},
-               },
-               {
-                       name: "should return empty slice when annotation key does not exist",
-                       namespace: &corev1.Namespace{
-                               ObjectMeta: metav1.ObjectMeta{
-                                       Name:        "example-namespace",
-                                       Annotations: map[string]string{},
-                               },
-                       },
-                       key:           "nonExistentKey",
-                       wantRuleNames: []string{},
-               },
-               {
-                       name: "should return empty slice when annotation value is empty",
-                       namespace: &corev1.Namespace{
-                               ObjectMeta: metav1.ObjectMeta{
-                                       Name: "example-namespace",
-                                       Annotations: map[string]string{
-                                               model.RulesKey: "",
-                                       },
-                               },
-                       },
-                       key:           model.RulesKey,
-                       wantRuleNames: []string{},
-               },
-       }
-
-       for i, tc := range testCases {
-               t.Run(testcase.Name(i, tc.name), func(t *testing.T) {
-                       ruleNames := getRuleNamesFromObject(tc.namespace, tc.key)
-                       assert.Equal(t, tc.wantRuleNames, ruleNames)
-               })
-       }
-}
-
-func TestMergeRuleNames(t *testing.T) {
-       tests := []struct {
-               name          string
-               ruleNames1    []string
-               ruleNames2    []string
-               wantRuleNames []string
-       }{
-               {
-                       name:          "Both slices empty",
-                       ruleNames1:    []string{},
-                       ruleNames2:    []string{},
-                       wantRuleNames: []string{},
-               },
-               {
-                       name:          "First slice empty, second slice with elements",
-                       ruleNames1:    []string{},
-                       ruleNames2:    []string{"rule1", "rule2"},
-                       wantRuleNames: []string{"rule1", "rule2"},
-               },
-               {
-                       name:          "Second slice empty, first slice with elements",
-                       ruleNames1:    []string{"rule1", "rule2"},
-                       ruleNames2:    []string{},
-                       wantRuleNames: []string{"rule1", "rule2"},
-               },
-               {
-                       name:          "No duplicate ruleNames",
-                       ruleNames1:    []string{"rule1", "rule3"},
-                       ruleNames2:    []string{"rule2", "rule4"},
-                       wantRuleNames: []string{"rule1", "rule3", "rule2", "rule4"},
-               },
-               {
-                       name:          "Some duplicate ruleNames",
-                       ruleNames1:    []string{"rule1", "rule3"},
-                       ruleNames2:    []string{"rule3", "rule4"},
-                       wantRuleNames: []string{"rule1", "rule3", "rule4"},
-               },
-               {
-                       name:          "All ruleNames duplicated",
-                       ruleNames1:    []string{"rule1", "rule2"},
-                       ruleNames2:    []string{"rule1", "rule2"},
-                       wantRuleNames: []string{"rule1", "rule2"},
-               },
-               {
-                       name:          "Mixed duplicates and unique ruleNames",
-                       ruleNames1:    []string{"rule1", "rule3", "rule5"},
-                       ruleNames2:    []string{"rule2", "rule3", "rule6"},
-                       wantRuleNames: []string{"rule1", "rule3", "rule5", "rule2", "rule6"},
-               },
-       }
-
-       for i, tt := range tests {
-               t.Run(testcase.Name(i, tt.name), func(t *testing.T) {
-                       ruleNames := mergeRuleNames(tt.ruleNames1, tt.ruleNames2)
-                       assert.Equal(t, tt.wantRuleNames, ruleNames)
-               })
-       }
-}
diff --git a/controllers/namespacecontroller/namespace_controller.go b/controllers/namespacecontroller/namespace_controller.go
deleted file mode 100644
index d5ce551..0000000
--- a/controllers/namespacecontroller/namespace_controller.go
+++ /dev/null
@@ -1,108 +0,0 @@
-/*
-Copyright 2024.
-
-Licensed under the Apache License, Version 2.0 (the "License");
-you may not use this file except in compliance with the License.
-You may obtain a copy of the License at
-
-    http://www.apache.org/licenses/LICENSE-2.0
-
-Unless required by applicable law or agreed to in writing, software
-distributed under the License is distributed on an "AS IS" BASIS,
-WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-See the License for the specific language governing permissions and
-limitations under the License.
-*/
-
-package namespacecontroller
-
-import (
-       "context"
-       "fmt"
-
-       "github.com/kuoss/ingress-annotator/pkg/model"
-       corev1 "k8s.io/api/core/v1"
-       networkingv1 "k8s.io/api/networking/v1"
-       apierrors "k8s.io/apimachinery/pkg/api/errors"
-       "k8s.io/client-go/tools/record"
-       "k8s.io/client-go/util/retry"
-       ctrl "sigs.k8s.io/controller-runtime"
-       "sigs.k8s.io/controller-runtime/pkg/client"
-       "sigs.k8s.io/controller-runtime/pkg/reconcile"
-)
-
-// NamespaceReconciler reconciles a Namespace object
-type NamespaceReconciler struct {
-       client.Client
-       IngressReconciler reconcile.Reconciler
-       Recorder          record.EventRecorder
-}
-
-// +kubebuilder:rbac:groups=core,resources=namespaces,verbs=get;list;watch;update;patch
-// +kubebuilder:rbac:groups=core,resources=namespaces/status,verbs=get;update;patch
-// +kubebuilder:rbac:groups=core,resources=namespaces/finalizers,verbs=update
-
-// SetupWithManager sets up the controller with the Manager.
-func (r *NamespaceReconciler) SetupWithManager(mgr ctrl.Manager) error {
-       return ctrl.NewControllerManagedBy(mgr).
-               For(&corev1.Namespace{}).
-               Complete(r)
