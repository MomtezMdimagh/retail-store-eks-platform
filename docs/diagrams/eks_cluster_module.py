import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram
from diagrams.aws.compute import EKS, EC2
from diagrams.aws.management import CloudwatchLogs
from diagrams.aws.security import KMS

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("eks-cluster module", filename=os.path.join(_here, "generated", "eks-cluster-module"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    control_plane = EKS("control plane\n(API auth mode)")
    nodes = EC2("baseline managed\nnode group")
    kms = KMS("secrets\nencryption key")
    logs = CloudwatchLogs("control-plane logs")

    control_plane >> nodes
    control_plane >> kms
    control_plane >> logs
