import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram, Edge
from diagrams.aws.management import AmazonManagedGrafana, AmazonManagedPrometheus, CloudwatchLogs
from diagrams.programming.flowchart import PredefinedProcess as Blank

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("observability module", filename=os.path.join(_here, "generated", "observability-module"),
             show=False, direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    ksm = Blank("kube-state-metrics")
    node_exp = Blank("node-exporter")
    adot = Blank("ADOT collectors\n(platform/observability)")
    amp = AmazonManagedPrometheus("AMP")
    logs = CloudwatchLogs("CloudWatch Logs")
    amg = AmazonManagedGrafana("AMG\n(opt-in)")

    [ksm, node_exp] >> adot
    adot >> [amp, logs]
    amp >> Edge(style="dashed") >> amg
