import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram, Edge
from diagrams.aws.compute import EKS
from diagrams.aws.integration import Eventbridge, SQS
from diagrams.programming.flowchart import PredefinedProcess as Blank

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("karpenter module", filename=os.path.join(_here, "generated", "karpenter-module"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    events = Eventbridge("spot interruption\nrules")
    queue = SQS("interruption\nqueue")
    controller = EKS("Karpenter controller\n(Pod Identity)")
    nodeshape = Blank("EC2NodeClass +\nNodePools\n(platform/karpenter)")

    events >> queue >> controller
    controller >> Edge(style="dashed", label="provisions per") >> nodeshape
