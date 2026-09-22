import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram
from diagrams.aws.compute import EKS
from diagrams.aws.network import ELB, Route53
from diagrams.aws.security import SecretsManager
from diagrams.aws.storage import EBS
from diagrams.programming.flowchart import PredefinedProcess as Blank

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("eks-addons module", filename=os.path.join(_here, "generated", "eks-addons-module"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    eks = EKS("EKS cluster\n(Pod Identity)")

    lbc = ELB("Load Balancer\nController")
    ebs = EBS("EBS CSI\nDriver")
    csi = SecretsManager("Secrets Store\nCSI Driver")
    dns = Route53("ExternalDNS")
    metrics = Blank("metrics-server")

    eks >> [lbc, ebs, csi, dns, metrics]
