from kubernetes import client, config
import time


config.load_kube_config()
v1 = client.CoreV1Api()

somePodsAreNotReady=True

#TODO add timeout

while somePodsAreNotReady:
    time.sleep(5)
    somePodsAreNotReady=False
    all_pods = v1.list_pod_for_all_namespaces(watch=False)
    for pod in all_pods.items:
        for container_status in pod.status.container_statuses:
            if container_status.ready == False:
                try:
                    is_completed = container_status.state.terminated.reason == 'Completed'
                except Exception as e:
                    is_completed = False
                if is_completed == False :
                    somePodsAreNotReady=True
