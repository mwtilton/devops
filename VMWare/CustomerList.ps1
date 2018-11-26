Connect-CIserver 10.20.0.4

(Get-OrgVdc).ExtensionData.GetEdgeGateways().record | select Name,GatewayStatus