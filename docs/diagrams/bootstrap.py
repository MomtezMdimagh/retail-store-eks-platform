import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Cluster, Diagram
from diagrams.aws.compute import ECR
from diagrams.aws.security import IAMRole
from diagrams.aws.storage import S3
from diagrams.onprem.ci import GithubActions

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("bootstrap", filename=os.path.join(_here, "generated", "bootstrap"), show=False,
             direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    ci = GithubActions("GitHub Actions")

    with Cluster("Bootstrap (run once, by hand)"):
        state = S3("Terraform state")
        role = IAMRole("OIDC deploy role")
        ecr = ECR("images + Helm charts")

    ci >> role
    ci >> ecr
