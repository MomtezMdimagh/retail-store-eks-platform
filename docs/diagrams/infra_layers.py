import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram
from diagrams.programming.flowchart import PredefinedProcess as Blank

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.4", "ranksep": "0.7", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("infrastructure/live layer order", filename=os.path.join(_here, "generated", "infra-layers"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    network = Blank("10-network")
    cluster = Blank("20-cluster")
    addons = Blank("30-addons")
    karpenter = Blank("40-karpenter")
    data_plane = Blank("50-data-plane")
    argocd = Blank("60-argocd")
    observability = Blank("70-observability")

    network >> cluster >> addons >> karpenter >> data_plane >> argocd >> observability
