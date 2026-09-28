"""
Generates docs/diagrams/generated/main-architecture.png - the top-level architecture diagram
embedded in the repo root README.

Regenerate after any structural change:
    python docs/diagrams/main_architecture.py

Requires Graphviz's `dot` binary on PATH (the diagrams library shells out to it) and the
`diagrams` Python package (`pip install diagrams`).
"""

import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import ECR, EKS, EC2AutoScaling, EC2Instances
from diagrams.aws.database import Dynamodb, ElasticacheForRedis, RDSMysqlInstance, RDSPostgresqlInstance
from diagrams.aws.devtools import XRay
from diagrams.aws.integration import SQS, Eventbridge
from diagrams.aws.management import AmazonManagedPrometheus, CloudwatchLogs
from diagrams.aws.network import ALB, InternetGateway, NATGateway, PublicSubnet, Route53
from diagrams.aws.security import IAMRole, KMS, SecretsManager
from diagrams.aws.storage import S3
from diagrams.k8s.compute import DaemonSet, Deployment
from diagrams.k8s.ecosystem import Helm
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.client import Users
from diagrams.onprem.gitops import ArgoCD
from diagrams.onprem.iac import Terraform
from diagrams.onprem.vcs import Github

GRAPH_ATTR = {
    "fontsize": "30",
    "fontname": "Helvetica-Bold",
    "bgcolor": "white",
    "pad": "0.6",
    "nodesep": "0.55",
    "ranksep": "1.0",
    "splines": "spline",
    "labelloc": "t",
}
NODE_ATTR = {"fontsize": "13", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "11", "fontname": "Helvetica", "color": "gray40"}

# Consistent cluster styling, loosely following AWS's own architecture-diagram conventions.
AWS_CLOUD = {"bgcolor": "#F7F9FC", "pencolor": "#232F3E", "penwidth": "2", "fontsize": "16", "fontname": "Helvetica-Bold"}
REGION = {"bgcolor": "#FFFFFF", "pencolor": "#147EBA", "style": "dashed", "penwidth": "1.5", "fontsize": "14"}
VPC = {"bgcolor": "#F2FAF2", "pencolor": "#248814", "penwidth": "1.5", "fontsize": "14", "fontname": "Helvetica-Bold"}
AZ = {"bgcolor": "#FFFFFF", "pencolor": "#147EBA", "style": "dashed", "fontsize": "13"}
PUBLIC = {"bgcolor": "#EAF5E6", "pencolor": "#7AA116", "fontsize": "11"}
PRIVATE = {"bgcolor": "#E6F2F8", "pencolor": "#147EBA", "fontsize": "11"}
EKS_STYLE = {"bgcolor": "#FFF6EA", "pencolor": "#ED7100", "penwidth": "1.5", "fontsize": "14", "fontname": "Helvetica-Bold"}
GROUP = {"bgcolor": "#FFFFFF", "pencolor": "#AAB7C4", "fontsize": "12"}
EXTERNAL = {"bgcolor": "#F4F4F6", "pencolor": "#6B7785", "penwidth": "1.5", "fontsize": "14", "fontname": "Helvetica-Bold"}

with Diagram(
    "retail-store-eks-platform  |  production-shaped EKS on AWS",
    filename=os.path.join(_here, "generated", "main-architecture"),
    show=False,
    direction="TB",
    graph_attr=GRAPH_ATTR,
    node_attr=NODE_ATTR,
    edge_attr=EDGE_ATTR,
):
    # ---------------------------------------------------------------- delivery (outside AWS)
    with Cluster("Delivery - GitHub", graph_attr=EXTERNAL):
        app_repo = Github("app repo\n5 services + charts")
        platform_repo = Github("platform repo\nTerraform + GitOps")
        ci = GithubActions("GitHub Actions\nbuild & push (OIDC)")
        tf = Terraform("Terraform\n7 layered roots")
        app_repo >> ci
        platform_repo >> Edge(style="dashed") >> tf

    shoppers = Users("shoppers")

    with Cluster("AWS Cloud", graph_attr=AWS_CLOUD):
        with Cluster("Region us-east-1", graph_attr=REGION):

            with Cluster("Account foundations (bootstrap, applied once)", graph_attr=GROUP):
                ecr = ECR("ECR\nimages + charts")
                state = S3("S3 remote state\n(native locking)")
                oidc = IAMRole("GitHub OIDC\ndeploy role")
                kms = KMS("KMS\nsecrets encryption")

            dns = Route53("Route 53\n(ExternalDNS)")

            with Cluster("VPC  10.0.0.0/16", graph_attr=VPC):
                igw = InternetGateway("Internet Gateway")
                alb = ALB("Application Load Balancer\n(AWS LB Controller)")

                azs = []
                for az, nat_here in (("us-east-1a", True), ("us-east-1b", False), ("us-east-1c", False)):
                    with Cluster(f"Availability Zone {az}", graph_attr=AZ):
                        with Cluster("public subnet", graph_attr=PUBLIC):
                            if nat_here:
                                nat = NATGateway("NAT Gateway\n(single, cost-fixed)")
                            else:
                                PublicSubnet("ALB subnet")
                        with Cluster("private subnet", graph_attr=PRIVATE):
                            azs.append(EC2Instances("worker nodes\non-demand + spot"))

                with Cluster("Amazon EKS  (Pod Identity everywhere - no IRSA)", graph_attr=EKS_STYLE):
                    control_plane = EKS("EKS control plane\nv1.36, API auth")

                    with Cluster("Platform add-ons", graph_attr=GROUP):
                        karpenter = EC2AutoScaling("Karpenter\nnode autoscaling")
                        lbc = ALB("AWS LB\nController")
                        csi = SecretsManager("Secrets Store\nCSI driver")
                        extdns = Route53("ExternalDNS")

                    with Cluster("GitOps", graph_attr=GROUP):
                        argocd = ArgoCD("Argo CD\napp-of-apps")
                        helm = Helm("Helm charts\n(OCI from ECR)")
                        argocd >> helm

                    with Cluster("Retail store workloads  (HPA + PDB + zone spread)", graph_attr=GROUP):
                        ui = Deployment("ui")
                        catalog = Deployment("catalog")
                        cart = Deployment("cart")
                        checkout = Deployment("checkout")
                        orders = Deployment("orders")

                    with Cluster("Observability", graph_attr=GROUP):
                        adot = DaemonSet("ADOT collectors\n(OpenTelemetry)")

                    control_plane >> Edge(style="dashed", color="gray60") >> karpenter
                    helm >> Edge(label="deploys") >> [ui, catalog, cart, checkout, orders]

            with Cluster("Managed data plane (private, SG-restricted)", graph_attr=GROUP):
                secrets = SecretsManager("Secrets Manager\nDB credentials")
                mysql = RDSMysqlInstance("RDS MySQL\ncatalog")
                ddb = Dynamodb("DynamoDB\ncart")
                redis = ElasticacheForRedis("ElastiCache Redis\ncheckout")
                postgres = RDSPostgresqlInstance("RDS PostgreSQL\norders")
                queue = SQS("SQS + DLQ\norders events")

            with Cluster("Observability backends", graph_attr=GROUP):
                amp = AmazonManagedPrometheus("Managed Prometheus\n(metrics)")
                cwl = CloudwatchLogs("CloudWatch Logs")
                xray = XRay("X-Ray\n(traces)")

            with Cluster("Spot interruption handling", graph_attr=GROUP):
                events = Eventbridge("EventBridge rules")
                interrupt_q = SQS("interruption queue")
                events >> interrupt_q

    # ---------------------------------------------------------------- flows
    # Cross-cutting edges use constraint="false" so they are drawn without distorting the layout
    # (otherwise e.g. the Karpenter edge drags one AZ out of line with the other two).
    X = {"constraint": "false"}
    ci >> Edge(label="assume role (OIDC)", color="#147EBA") >> oidc
    ci >> Edge(label="push images + charts", color="#147EBA") >> ecr
    tf >> Edge(style="dashed", color="#7B42BC") >> state
    platform_repo >> Edge(label="GitOps sync", style="dashed", color="#EF7B4D", **X) >> argocd
    ecr >> Edge(label="pull charts", style="dashed", color="gray55", **X) >> helm

    shoppers >> dns >> igw >> alb >> Edge(color="#248814") >> ui
    nat >> Edge(style="dotted", color="gray60", label="egress") >> igw
    lbc >> Edge(style="dotted", color="gray60") >> alb
    karpenter >> Edge(style="dotted", color="#ED7100", label="provisions nodes", **X) >> azs
    interrupt_q >> Edge(style="dotted", color="gray60", label="drain on interruption", **X) >> karpenter
    control_plane >> Edge(style="dotted", color="gray60", **X) >> kms

    catalog >> Edge(color="#3B48CC") >> mysql
    cart >> Edge(color="#3B48CC") >> ddb
    checkout >> Edge(color="#3B48CC") >> redis
    orders >> Edge(color="#3B48CC") >> postgres
    csi >> Edge(style="dashed", color="#DD344C", label="mount creds", **X) >> secrets

    adot >> Edge(color="#E7157B") >> [amp, cwl, xray]
