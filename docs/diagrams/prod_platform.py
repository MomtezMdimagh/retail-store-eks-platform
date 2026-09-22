import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Cluster, Diagram, Edge
from diagrams.programming.flowchart import PredefinedProcess as Blank
from diagrams.onprem.gitops import ArgoCD

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("gitops/environments/prod/platform", filename=os.path.join(_here, "generated", "prod-platform"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    argocd = ArgoCD("prod's platform.yaml\n(2nd source)")

    with Cluster("prod platform (env-coupled)"):
        nodeclass = Blank("karpenter/\nec2nodeclass.yaml")
        logs = Blank("observability/\nadot-collector-logs.yaml")
        metrics = Blank("observability/\nadot-collector-metrics.yaml")

    argocd >> Edge(label="sync") >> [nodeclass, logs, metrics]
