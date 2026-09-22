import os

_here = os.path.dirname(os.path.abspath(__file__))
os.environ["PATH"] += r";C:\Program Files\Graphviz\bin"

from diagrams import Cluster, Diagram
from diagrams.aws.network import InternetGateway, NATGateway, PrivateSubnet, PublicSubnet

GRAPH_ATTR = {"fontsize": "18", "fontname": "Helvetica-Bold", "bgcolor": "white", "pad": "0.35",
              "nodesep": "0.5", "ranksep": "0.8", "splines": "spline"}
NODE_ATTR = {"fontsize": "12", "fontname": "Helvetica"}
EDGE_ATTR = {"fontsize": "10", "fontname": "Helvetica", "color": "gray35"}

with Diagram("vpc module", filename=os.path.join(_here, "generated", "vpc-module"), show=False,
             direction="LR", graph_attr=GRAPH_ATTR, node_attr=NODE_ATTR, edge_attr=EDGE_ATTR):
    igw = InternetGateway("IGW")

    with Cluster("VPC - 3 AZs"):
        public = PublicSubnet("public subnets")
        nat = NATGateway("NAT GW\n(single, shared)")
        private = PrivateSubnet("private subnets")
        public >> nat >> private

    igw >> public
