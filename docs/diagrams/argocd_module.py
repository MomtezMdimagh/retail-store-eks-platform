import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram, Edge
from diagrams.aws.compute import ECR
from diagrams.programming.flowchart import PredefinedProcess as Blank
from diagrams.k8s.compute import Cronjob
from diagrams.onprem.gitops import ArgoCD

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("argocd module", filename=os.path.join(_here, "generated", "argocd-module"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    cron = Cronjob("ECR token\nrefresh (6h)")
    argocd = ArgoCD("ArgoCD")
    ecr = ECR("OCI chart\nregistry")
    bootstrap = Blank("bootstrap Application\n(app-of-apps)")

    cron >> Edge(style="dashed", label="refreshes creds") >> argocd
    argocd >> Edge(label="pulls charts") >> ecr
    argocd >> bootstrap
