@tool
class_name AnomalyHelper extends Node

@export var scan_anomalies: bool:
    set(value):
        scan_anomalies = false
        get_anomaly_info()

func get_anomaly_info():
    var root = get_tree().get_root()
    prints("Scanning for anomalies using", root, "as root")
    var anomalies = find_anomalies_recursive(root)
    prints("Found", anomalies.size(), "anomalies")

func find_anomalies_recursive(node: Node):
    var anomalies = []
    for child in node.get_children():
        if child is Anomaly:
            anomalies.append(child)
        anomalies.append_array(find_anomalies_recursive(child))
    return anomalies