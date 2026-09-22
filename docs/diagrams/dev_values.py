import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram
from diagrams.programming.flowchart import PredefinedProcess as Blank
from diagrams.k8s.compute import Deployment
from diagrams.onprem.ci import GithubActions

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("gitops/environments/dev/values", filename=os.path.join(_here, "generated", "dev-values"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    ci = GithubActions("app repo CI\n(every build)")
    values = Blank("values-<service>.yaml\n(image.tag)")
    app = Deployment("Application")

    ci >> values >> app
