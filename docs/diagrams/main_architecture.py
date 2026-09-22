"""
Generates docs/diagrams/generated/main-architecture.png - the top-level architecture diagram
embedded in the repo root README.

Regenerate after any structural change:
    python docs/diagrams/main_architecture.py

Requires Graphviz's `dot` binary on PATH (the diagrams library shells out to it) and the
`diagrams` Python package (`pip install diagrams`).
"""

import os

os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import EKS, ECR
from diagrams.aws.database import RDSMysqlInstance, RDSPostgresqlInstance, Dynamodb, ElasticacheForRedis
from diagrams.aws.integration import SQS
from diagrams.aws.management import AmazonManagedPrometheus, CloudwatchLogs
from diagrams.aws.network import VPC, InternetGateway, NATGateway, ELB
from diagrams.aws.security import IAMRole, SecretsManager
from diagrams.aws.storage import S3
from diagrams.k8s.compute import Deployment
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.gitops import ArgoCD
from diagrams.onprem.vcs import Github

GRAPH_ATTR = {
    "fontsize": "24",
    "fontname": "Helvetica-Bold",
    "bgcolor": "white",
    "pad": "0.5",
    "nodesep": "0.55",
    "ranksep": "1.0",
    "splines": "spline",
    "compound": "true",
}
NODE_ATTR = {"fontsize": "13", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "11", "fontname": "Helvetica", "color": "gray35"}

with Diagram(
    "retail-store-eks-platform - architecture",
    filename="generated/main-architecture",
    show=False,
    direction="TB",
    graph_attr=GRAPH_ATTR,
    node_attr=NODE_ATTR,
    edge_attr=EDGE_ATTR,
):
    with Cluster("Source control & CI"):
        app_repo = Github("app repo")
        platform_repo = Github("platform repo")
        ci = GithubActions("GitHub Actions\n(OIDC, no long-lived keys)")
        app_repo >> ci

    with Cluster("AWS account - us-east-1 (one per environment: dev, prod)"):
        with Cluster("Bootstrap - run once by hand"):
            state = S3("Terraform state\n(S3 native lock)")
            oidc_role = IAMRole("GitHub OIDC\ndeploy role")
            ecr = ECR("ECR\nimages + Helm charts")

        with Cluster("VPC"):
            igw = InternetGateway("IGW")
            nat = NATGateway("NAT GW\n(single, cost-fixed)")
            igw >> nat

            with Cluster("EKS cluster  (Pod Identity everywhere, no IRSA)"):
                control_plane = EKS("control plane")

                with Cluster("Karpenter-managed nodes"):
                    nodes = EKS("on-demand +\nspot NodePools")

                lbc = ELB("AWS LB\nController")
                csi = SecretsManager("Secrets Store\nCSI Driver")
                argocd = ArgoCD("ArgoCD\n(app-of-apps)")

                with Cluster("Workloads"):
                    ui = Deployment("ui")
                    catalog = Deployment("catalog")
                    cart = Deployment("cart")
                    checkout = Deployment("checkout")
                    orders = Deployment("orders")

                with Cluster("Observability (ADOT)"):
                    amp = AmazonManagedPrometheus("AMP\n(metrics)")
                    logs = CloudwatchLogs("CloudWatch\n(logs)")

                control_plane >> nodes
                nodes >> Edge(color="gray60", style="dashed") >> [lbc, csi]
                argocd >> Edge(label="sync") >> [ui, catalog, cart, checkout, orders]
                nodes >> Edge(color="gray60", style="dashed") >> [amp, logs]

            with Cluster("Data plane"):
                mysql = RDSMysqlInstance("catalog-mysql")
                postgres = RDSPostgresqlInstance("orders-postgres")
                orders_q = SQS("orders + DLQ")
                ddb = Dynamodb("cart-dynamodb")
                redis = ElasticacheForRedis("checkout-redis")
                postgres >> orders_q

            catalog >> Edge(color="gray20") >> mysql
            orders >> Edge(color="gray20") >> postgres
            cart >> Edge(color="gray20") >> ddb
            checkout >> Edge(color="gray20") >> redis

        ci >> Edge(label="assume role") >> oidc_role
        ci >> Edge(label="push images") >> ecr
        platform_repo >> Edge(label="git sync", style="dashed", color="gray50") >> argocd
