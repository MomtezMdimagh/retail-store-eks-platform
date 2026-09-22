import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram, Edge
from diagrams.programming.flowchart import PredefinedProcess as Blank
from diagrams.onprem.gitops import ArgoCD

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("platform/", filename=os.path.join(_here, "generated", "platform-overview"), show=False,
             direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    argocd = ArgoCD("every environment's\nArgoCD")

    karpenter = Blank("karpenter/\nNodePools")
    observability = Blank("observability/\ncollectors")
    argo_project = Blank("argocd/\nAppProject")

    argocd >> Edge(label="sync") >> [karpenter, observability, argo_project]
