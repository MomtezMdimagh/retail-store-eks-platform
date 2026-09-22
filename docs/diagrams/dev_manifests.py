import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Diagram, Edge
from diagrams.aws.security import SecretsManager
from diagrams.programming.flowchart import PredefinedProcess as Blank
from diagrams.k8s.compute import Deployment

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("gitops/environments/dev/manifests",
             filename=os.path.join(_here, "generated", "dev-manifests"), show=False, direction="LR",
             graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    secret = SecretsManager("RDS master-user\nsecret")
    spc = Blank("SecretProviderClass")
    helper = Deployment("secret-sync-helper\n(mounts the CSI volume\nso syncing happens at all)")
    k8s_secret = Blank("k8s Secret\n(catalog-db / orders-db)")
    pod = Deployment("catalog / orders pod\n(envFrom)")

    secret >> spc
    spc >> Edge(label="mounted by") >> helper
    spc >> Edge(label="secretObjects sync") >> k8s_secret >> pod
