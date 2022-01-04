<%@ Page Language="c#" EnableEventValidation="false" AutoEventWireup="true" %>

<%@ Import Namespace="System.Globalization " %>
<%--
    Original code: Brian Pederson
    Link to original code: https://briancaos.wordpress.com/2014/11/11/sitecore-job-viewer-see-what-sitecore-is-doing-behind-your-back/

    Name: Maulik Darji
    Idea: I have extended Brian's idea of Sitecore Job viewer and added a code for updating the Priority of the Job
        
    
--%>


<script runat="server">

    void Page_Load(object sender, System.EventArgs e)
    {
        repJobs.DataBind();
        StringBuilder stringBuilder = new StringBuilder();
        this.ShowRefreshStatus(stringBuilder);
        this.lt.Text = stringBuilder.ToString();

    }

    public IEnumerable<Sitecore.Jobs.Job> FinishedJobs
    {
        get
        {
            if (!cbShowFinished.Checked)
                return Sitecore.Jobs.JobManager.GetJobs().Where(job => job.IsDone == false).OrderBy(job => job.QueueTime);
            return Sitecore.Jobs.JobManager.GetJobs().OrderBy(job => job.QueueTime);
        }
    }

    public IEnumerable<Sitecore.Jobs.Job> QueuedJobs
    {
        get
        {
            if (!cbShowFinished.Checked)
                return Sitecore.Jobs.JobManager.GetJobs().Where(job => job.IsDone == false).OrderBy(job => job.QueueTime);
            return Sitecore.Jobs.JobManager.GetJobs().OrderBy(job => job.QueueTime);
        }
    }


    public IEnumerable<Sitecore.Jobs.Job> Jobs
    {
        get
        {
            if (!cbShowFinished.Checked)
                return Sitecore.Jobs.JobManager.GetJobs().Where(job => job.IsDone == false).OrderBy(job => job.QueueTime);
            return Sitecore.Jobs.JobManager.GetJobs().OrderBy(job => job.QueueTime);
        }
    }

    protected string GetJobText(Sitecore.Jobs.Job job)
    {
        return string.Format("{0}\n\n{1}\n\n{2}", job.Name, job.Category, GetJobMessages(job));
    }

    protected string GetJobMessages(Sitecore.Jobs.Job job)
    {
        System.Text.StringBuilder sb = new StringBuilder();
        if (job.Options.ContextUser != null)
            sb.AppendLine("Context User: " + job.Options.ContextUser.Name);
        sb.AppendLine("Priority: " + job.Options.Priority.ToString());
        sb.AppendLine("Messages:");
        foreach (string s in job.Status.Messages)
            sb.AppendLine(s);
        return sb.ToString();
    }

    protected string GetJobColor(Sitecore.Jobs.Job job)
    {
        if (job.IsDone)
            return "#737373";
        return "#000";
    }

    protected void cbShowFinished_CheckedChanged(object sender, EventArgs e)
    {
        repJobs.DataBind();
    }

    protected void btn_Click(object sender, CommandEventArgs e)
    {

        switch (e.CommandName)
        {
            case "btnPriority":
                // Do some stuff when the Edit button is clicked.
                IncreasePriority(e.CommandArgument.ToString());
                break;

            // Other commands here.

            default:
                break;
        }

    }


    protected void btn_Click(object sender, EventArgs e)
    {
        Button btn = (Button)sender;
        RepeaterItem item = (RepeaterItem)btn.NamingContainer;
        Button btnPriority = (Button)item.FindControl("btnPriority");

        var currentJob = (Sitecore.Jobs.Job)item.DataItem;

        if (currentJob != null)
        {
            Response.Write("Current Job is :" + currentJob.Name);
        }
        else
        {
            Response.Write("Current Job is not found");
        }

        //bool btn0Clicked = btn == btnNewNumber0;
        //btnNewNumber0.Visible = !btn0Clicked;
        //btnNewNumber1.Visible = btn0Clicked;
        //// now call your webservice, you have all you need here
        //Label lblName = (Label)item.FindControl("lblName");
        //Label lblSurname = (Label)item.FindControl("lblSurname");
        //Label lblNumber = (Label)item.FindControl("lblNumber");
        //DropDownList ddlColor = (DropDownList)item.FindControl("ddlColor");
        // now call your webservice, you get the color-selection via ddlColor.SelectedValue
    }

    protected string IncreasePriority(string runningJobName)
    {
        var runningJob = Sitecore.Jobs.JobManager.GetJob(runningJobName);
        if (runningJob != null)
        {
            Response.Write("Current Job is :" + runningJob.Name);
            runningJob.Options.Priority = System.Threading.ThreadPriority.Highest;
        }
        else
        {
            Response.Write("Current Job is not found");
        }


        Response.Write("Current Job priority is :" + runningJob.Options.Priority.ToString());
        //runningJob.Options.Priority = System.Threading.ThreadPriority.Highest;
        return runningJob.Options.Priority.ToString();
    }

    protected void ShowRefreshStatus(StringBuilder stringBuilder)
    {
        int result;
        int.TryParse(this.Request.QueryString["refresh"], out result);
        stringBuilder.Append(string.Format("Last updated: {0}. ", (object)DateTime.Now.ToString((IFormatProvider)CultureInfo.InvariantCulture)));
        int[] numArray = new int[7] { 1, 2, 5, 10, 20, 30, 60 };
        stringBuilder.Append(string.Format("Refresh each <a href='jobsView.aspx' class='refresh-link {0}'>No Refresh</a>", result == 0 ? (object)"refresh-selected" : (object)string.Empty));
        foreach (int num in numArray)
        {
            string str1 = result == num ? "refresh-selected" : string.Empty;
            string str2 = string.Format(", <a href='jobsView.aspx?refresh={0}&finishedjobs={2}' class='refresh-link {1}'>{0} sec</a>", (object)num, (object)str1, cbShowFinished.Checked);
            stringBuilder.Append(str2);
        }
        stringBuilder.Append("<br /><br />");
    }
</script>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<html>
<head>
    <title>Job Viewer by Maulik Darji</title>
    <link href="/default.css" rel="stylesheet">
</head>
<body style="font-size: 14px">
    <form runat="server">
        <div class="wf-content">
            <h1>
                <a href="/sitecore/admin/">Administration Tools</a> - Jobs Viewer
            </h1>
            <br />
            <asp:Literal runat="server" ID="lt"></asp:Literal>
            <script type="text/javascript">
                function getQueryString() {
                    var result = {}, queryString = location.search.substring(1), re = /([^&=]+)=([^&]*)/g, m;
                    while (m = re.exec(queryString)) {
                        result[decodeURIComponent(m[1])] = decodeURIComponent(m[2]);
                    }

                    return result;
                }

                var str = getQueryString()["refresh"];
                if (str != undefined) {
                    c = parseInt(str) * 1000;
                    setTimeout("document.location.href = document.location.href;", c);
                }

                var strFinishedJobs = getQueryString()["finishedjobs"];
                if (strFinishedJobs != undefined) {
                    if (strFinishedJobs == "True") {
                        //   alert("finished jobs are shown");
                        document.getElementById('<%=cbShowFinished.ClientID%>').checked = true;

                    }
                    else {
                        //  alert("finished jobs are NOT shown");
                        document.getElementById('<%=cbShowFinished.ClientID%>').checked = false;


                    }
                }

            </script>
        </div>
        <div style="padding: 10px; background-color: #efefef; border-bottom: solid 1px #aaa; border-top: solid 1px white">
            <div style="float: left; width: 200px; padding-top: 4px">
                <asp:CheckBox ID="cbShowFinished" runat="server" Text="Show finished jobs" Checked="false" OnCheckedChanged="cbShowFinished_CheckedChanged" AutoPostBack="true" />
            </div>
            <div style="float: right;">
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" BackColor="Green" ForeColor="White" Width="100px" Height="30px" />
            </div>
            <div style="clear: both; height: 1px">&nbsp;</div>
        </div>

        <div style="padding-top: 0px">
            <asp:Repeater ID="repJobs" runat="server" DataSource="<%# Jobs %>">
                <HeaderTemplate>
                    <table style="width: 100%">
                        <thead style="background-color: #eaeaea">
                            <td>Job</td>
                            <td>Category</td>
                            <td>Status</td>
                            <td>Processed</td>
                            <td>QueueTime</td>
                            <td>Priority</td>
                            <td>Increase Priority</td>
                        </thead>
                </HeaderTemplate>
                <FooterTemplate>
                    </table>
                </FooterTemplate>
                <ItemTemplate>
                    <tr style="background-color: beige; color: <%# GetJobColor((Container.DataItem as Sitecore.Jobs.Job)) %>" title="<%# GetJobText((Container.DataItem as Sitecore.Jobs.Job)) %>">
                        <td>
                            <%# Sitecore.StringUtil.Clip((Container.DataItem as Sitecore.Jobs.Job).Name, 50, true) %>
                        </td>
                        <td>
                            <%# Sitecore.StringUtil.Clip((Container.DataItem as Sitecore.Jobs.Job).Category, 50, true) %>
                        </td>
                        <td>
                            <%# (Container.DataItem as Sitecore.Jobs.Job).Status.State %>
                        </td>
                        <td>
                            <%# (Container.DataItem as Sitecore.Jobs.Job).Status.Processed %> /
                <%# (Container.DataItem as Sitecore.Jobs.Job).Status.Total %>
                        </td>
                        <td>
                            <%# (Container.DataItem as Sitecore.Jobs.Job).QueueTime.ToLocalTime() %>
                        </td>
                        <td>
                            <%# (Container.DataItem as Sitecore.Jobs.Job).Options.Priority.ToString() %>
                        </td>
                        <td>
                            <%--                            <%
                                var currentJob = Container.DataItem as Sitecore.Jobs.Job;
                                %>--%>
                            <asp:Button ID="btnPriority" runat="server" Text="Priority UP" OnCommand="btn_Click" CommandName="btnPriority" CommandArgument='<%# Eval("Name") %>'
                                BackColor="Blue" ForeColor="White" Width="100px" Height="30px" />


                            <%--                            <asp:ImageButton ID="phImage" runat="server" ImageUrl='<%#"~/ImageHandler.ashx?id=" + DataBinder.Eval(Container.DataItem, "PhotoID")%>'  OnCommand="btn_Click" CommandName="btnPriority" CommandArgument='<%# Eval((Container.DataItem as Sitecore.Jobs.Job).Name) %>' />


                            <asp:LinkButton ID="LinkButton1" runat="server" CommandName="Edit">Edit</asp:LinkButton>--%>

                        </td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </div>

    </form>
</body>
</html>
