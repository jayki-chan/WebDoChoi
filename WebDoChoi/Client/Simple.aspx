<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Simple.aspx.cs" Inherits="WebDoChoi.Client.Simple" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Simple Test</title>
</head>
<body>
    <form id="form1" runat="server">
        <div style="padding: 20px;">
            <h1>Simple Test Page</h1>
            
            <asp:Label ID="lblResult" runat="server" Text="Click button to test" 
                       style="display:block; margin:10px 0; padding:10px; background:#f0f0f0;"></asp:Label>
            
            <asp:Button ID="btnTest" runat="server" Text="Test Button" 
                        OnClick="btnTest_Click" style="padding:10px 20px; margin:5px;" />
            
            <asp:Button ID="btnTestDB" runat="server" Text="Test Database" 
                        OnClick="btnTestDB_Click" style="padding:10px 20px; margin:5px;" />
        </div>
    </form>
</body>
</html>