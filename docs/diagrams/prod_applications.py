import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Cluster, Diagram, Edge
from diagrams.programming.flowchart import PredefinedProcess as Blank
from diagrams.k8s.compute import Deployment
from diagrams.onprem.gitops import ArgoCD

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.45", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("gitops/environments/prod/applications", filename=os.path.join(_here, "generated", "prod-applications"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    argocd = ArgoCD("ArgoCD\n(prod's own instance)")

    with Cluster("prod Applications"):
        ui = Deployment("ui")
        catalog = Deployment("catalog")
        cart = Deployment("cart")
        checkout = Deployment("checkout")
        orders = Deployment("orders")
        platform_app = Blank("platform.yaml\n(multi-source)")

    argocd >> Edge(label="sync") >> [ui, catalog, cart, checkout, orders, platform_app]
