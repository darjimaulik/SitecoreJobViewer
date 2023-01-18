<%@ Page Language="c#" Inherits="Sitecore.sitecore.admin.AdminPage" EnableEventValidation="false" AutoEventWireup="true" %>
 
<%--<%@ Page Language="c#" EnableEventValidation="false" AutoEventWireup="true" %>--%>
 

<%@ Import Namespace="System.Globalization " %>
<%--
    Original code: Brian Pederson
    Link to original code: https://briancaos.wordpress.com/2014/11/11/sitecore-job-viewer-see-what-sitecore-is-doing-behind-your-back/

    Name: Maulik Darji
    Idea: I have extended Brian's idea of Sitecore Job viewer. 
            Added: Options for all the types of jobs in same page without extra click
            Added a code for updating the Priority of the "Queued" Job
   
--%>



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<html>
<head>
    <title>Job Viewer by Maulik Darji</title>
    <link rel="Stylesheet" type="text/css" href="/sitecore/shell/themes/standard/default/WebFramework.css" />
    <link rel="Stylesheet" type="text/css" href="./default.css" />

    <style type="text/css">
        body {
            background-color: #fff;

            font-size:12px;

        }

        .content {
            background-color: #fff;
            margin: 0 auto; 
        }
        hr {

            border: 1px solid #000;

        }
        table {
            width: 100%;
            margin: 0 auto; 
        }
        td {
            border-spacing: 1px;
            border-collapse: collapse;
            padding: 2px;

            /*color: #000*/
        }
        thead {
            background-color: antiquewhite;
            font-weight: bold;
        }
        .category {
            width: 50px;
        }
        .Job {

            width: 100px;
            word-break: break-all;
        }

        .status, .queuetime, .processed {
            width: 50px;
            text-align: center;
        }

        .priority {
            width: 80px;
        }

 

        .wf-container {

            width: 90% !important;

            margin: 0 auto;

        }

 

        .divTitle {

            padding: 10px;

            background-color: #fff;

            border-bottom: solid 1px #aaa;

            border-top: solid 1px white;

            text-align: center;

        }

    </style>
</head>
<body style="font-size: 14px">

    <form id="Form1" runat="server" class="wf-container">

        <div class="wf-content content">

 

            <div class="divTitle">

                <h1>
                    <a href="/sitecore/admin/">Administration Tools</a> - Jobs Viewer
                </h1>
                <br />
                <asp:Literal runat="server" ID="lt"></asp:Literal>

                <br />

                <asp:Literal runat="server" ID="ltlMessage"></asp:Literal>

                <br />
                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" BackColor="Green" ForeColor="White" Width="100px" Height="30px" />
            </div>

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
            </script>

            <br />

            <hr />

            <br />

            <div class="divTitle">
                <div style="float: left; width: 200px; padding-top: 4px">
                    <h2>Running Jobs</h2>
                </div>

                <div style="clear: both; height: 1px">&nbsp;</div>
            </div>


            <div >

                <asp:Repeater ID="repJobs" runat="server" DataSource="<%# Jobs %>">
                    <HeaderTemplate>
                        <table>
                            <thead>
                                <td class="job">Job</td>
                                <td class="category">Category</td>
                                <td class="status">Status</td>
                                <td class="processed">Processed</td>
                                <td class="queuetime">QueueTime</td>
                                <td class="priority">Priority</td>
                            </thead>
                    </HeaderTemplate>
                    <FooterTemplate>
                        </table>

                        <asp:Label ID="lblEmptyData" Text="No Data To Display" runat="server" Visible="false"> </asp:Label>

                    </FooterTemplate>
                    <ItemTemplate>
                        <tr style="background-color: white; color: <%# GetJobColor((Container.DataItem as Sitecore.Jobs.Job)) %>" title="<%# GetJobText((Container.DataItem as Sitecore.Jobs.Job)) %>">
                            <td class="Job">
                                <%# Sitecore.StringUtil.Clip((Container.DataItem as Sitecore.Jobs.Job).Name, 500, true) %>
                            </td>
                            <td class="category">
                                <%# Sitecore.StringUtil.Clip((Container.DataItem as Sitecore.Jobs.Job).Category, 50, true) %>
                            </td>
                            <td class="status">
                                <%# (Container.DataItem as Sitecore.Jobs.Job).Status.State %>
                            </td>
                            <td class="processed">
                                <%# GetProcessed(Container.DataItem as Sitecore.Jobs.Job) %>
                            </td>
                            <td class="queuetime">
                                <%# (Container.DataItem as Sitecore.Jobs.Job).QueueTime.ToLocalTime() %>
                            </td>
                            <td class="priority">
                                <%# (Container.DataItem as Sitecore.Jobs.Job).Options.Priority.ToString() %>
                            </td>

                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <hr />
            <br />
            <div style="padding: 10px; background-color: #fff; border-bottom: solid 1px #aaa; border-top: solid 1px white">
                <div style="float: left; width: 200px; padding-top: 4px">
                    <h2>There are <%= QueuedCount %> Queued Jobs</h2>
                </div>

                <div style="clear: both; height: 1px">&nbsp;</div>
            </div>               
            <br />
            <hr />

            <br />

            <div style="padding: 10px; background-color: #fff; border-bottom: solid 1px #aaa; border-top: solid 1px white">
                <div style="float: left; width: 200px; padding-top: 4px">
                    <h2>Queued Jobs</h2>
                </div>

                <div style="clear: both; height: 1px">&nbsp;</div>
            </div>               

            <div style="padding-top: 0px">
                <asp:Repeater ID="repQueued" runat="server" DataSource="<%# Top100QueuedJobs %>">
                    <HeaderTemplate>
                        <table>
                            <thead>
                                <td class="job">Job</td>
                                <td class="category">Category</td>
                                <td class="status">Status</td>
                                <td class="processed">Processed</td>
                                <td class="queuetime">QueueTime</td>
                                <td class="priority">Priority</td>

                                <td class="priority">Increase Priority</td>
                            </thead>
                    </HeaderTemplate>
                    <FooterTemplate>
                        </table>

                        <asp:Label ID="lblEmptyData" Text="No Data To Display" runat="server" Visible="false"> </asp:Label>

                    </FooterTemplate>
                    <ItemTemplate>
                        <tr style="background-color: white; color: <%# GetJobColor((Container.DataItem as Sitecore.Jobs.Job)) %>" title="<%# GetJobText((Container.DataItem as Sitecore.Jobs.Job)) %>">
                            <td class="Job">
                                <%# Sitecore.StringUtil.Clip((Container.DataItem as Sitecore.Jobs.Job).Name, 500, true) %>
                            </td>
                            <td class="category">
                                <%# Sitecore.StringUtil.Clip((Container.DataItem as Sitecore.Jobs.Job).Category, 50, true) %>
                            </td>
                            <td class="status">
                                <%# (Container.DataItem as Sitecore.Jobs.Job).Status.State %>
                            </td>
                            <td class="processed">
                                <%# GetProcessed(Container.DataItem as Sitecore.Jobs.Job) %>
                            </td>
                            <td class="queuetime">
                                <%# (Container.DataItem as Sitecore.Jobs.Job).QueueTime.ToLocalTime() %>
                            </td>
                            <td class="priority">
                                <%# (Container.DataItem as Sitecore.Jobs.Job).Options.Priority.ToString() %>
                            </td>
                            <td class="priority">

                                <asp:Button ID="btnPriority" runat="server" Text="Priority UP" OnCommand="btn_Click" CommandName="btnPriority" CommandArgument='<%# GetHandle(Container.DataItem as Sitecore.Jobs.Job) %>'
                                    BackColor="Blue" ForeColor="White" Width="100px" Height="30px" />
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        
            <br />

            <hr />
            <br />
            <div style="padding: 10px; background-color: #fff; border-bottom: solid 1px #aaa; border-top: solid 1px white">
                <div style="float: left; width: 200px; padding-top: 4px">
                    <h2>Finished Jobs</h2>
                </div>
                <div style="clear: both; height: 1px">&nbsp;</div>
            </div>

            <div style="padding-top: 0px">
                <asp:Repeater ID="repFinished" runat="server" DataSource="<%# FinishedJobs %>">
                    <HeaderTemplate>
                        <table>
                            <thead>
                                <td class="job">Job</td>
                                <td class="category">Category</td>
                                <td class="status">Status</td>
                                <td class="processed">Processed</td>
                                <td class="queuetime">QueueTime</td>
                                <td class="priority">Priority</td>

                            </thead>
                    </HeaderTemplate>
                    <FooterTemplate>
                        </table>
                    </FooterTemplate>
                    <ItemTemplate>
                        <tr style="background-color: white; color: <%# GetJobColor((Container.DataItem as Sitecore.Jobs.Job)) %>" title="<%# GetJobText((Container.DataItem as Sitecore.Jobs.Job)) %>">
                            <td class="Job">
                                <%# Sitecore.StringUtil.Clip((Container.DataItem as Sitecore.Jobs.Job).Name, 500, true) %>
                            </td>
                            <td class="category">
                                <%# Sitecore.StringUtil.Clip((Container.DataItem as Sitecore.Jobs.Job).Category, 50, true) %>
                            </td>
                            <td class="status">
                                <%# (Container.DataItem as Sitecore.Jobs.Job).Status.State %>
                            </td>
                            <td class="processed">
                                <%# GetProcessed(Container.DataItem as Sitecore.Jobs.Job) %>
                            </td>
                            <td class="queuetime">
                                <%# (Container.DataItem as Sitecore.Jobs.Job).QueueTime.ToLocalTime() %>
                            </td>
                            <td class="priority">
                                <%# (Container.DataItem as Sitecore.Jobs.Job).Options.Priority.ToString() %>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>


    </form>
</body>
</html>
<script runat="server">

    void Page_Load(object sender, System.EventArgs e)
    {
        repJobs.DataBind();
        repFinished.DataBind();
        repQueued.DataBind();

        StringBuilder stringBuilder = new StringBuilder();
        this.ShowRefreshStatus(stringBuilder);
        this.lt.Text = stringBuilder.ToString();

 

    }

    protected override void OnInit(EventArgs e)

    {

        CheckSecurity(true); //Required!

        base.OnInit(e);

    }

    public IEnumerable<Sitecore.Jobs.Job> FinishedJobs
    {
        get
        {
            return Sitecore.Jobs.JobManager.GetJobs().Where(job => job.IsDone == true).OrderBy(job => job.QueueTime);

        }
    }

    public IEnumerable<Sitecore.Jobs.Job> QueuedJobs
    {
        get
        {
            return Sitecore.Jobs.JobManager.GetJobs().Where(job => job.IsDone == false).Where(job => job.Status.State == Sitecore.Jobs.JobState.Queued).OrderBy(job => job.QueueTime);
        }
    }
    public int QueuedCount { get; set; }

    public List<Sitecore.Jobs.Job> Top100QueuedJobs
    {
        get
        {
            List<Sitecore.Jobs.Job> Jobs = Sitecore.Jobs.JobManager.GetJobs().Where(job => job.IsDone == false).Where(job => job.Status.State == Sitecore.Jobs.JobState.Queued).OrderBy(job => job.QueueTime).ToList();
           
            QueuedCount = Jobs.Count();
            if (Jobs != null && Jobs.Count() > 100)
            {
                return Jobs.Take(100).ToList();
            }
            else
            {
                return Jobs;
            }
        }
    }


    public IEnumerable<Sitecore.Jobs.Job> Jobs
    {
        get
        {
            return Sitecore.Jobs.JobManager.GetJobs().Where(job => job.IsDone == false).Where(job => job.Status.State != Sitecore.Jobs.JobState.Queued).OrderBy(job => job.QueueTime);

        }

        }

    protected string GetHandle(Sitecore.Jobs.Job job)

    {

        return string.Format("{0}", job.Handle.ToString());

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
    protected string GetProcessed(Sitecore.Jobs.Job job)
    {
        var total = job.Status.Total;
        return job.Status.Processed + (total > 0L ? " of " + total.ToString() : string.Empty);// + "/" + job.Status.Total;
    }
    protected string GetJobColor(Sitecore.Jobs.Job job)
    {
        if (job.IsDone)
        {
            return "#737373";
        }
        else if (job.Status.State == Sitecore.Jobs.JobState.Queued)
        {
            return "#00f";
        }
        return "Green";
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
    }

    protected string IncreasePriority(string runningJobName)
    {
        var message = "<br>";
        var newHandle = Sitecore.Handle.Parse(runningJobName);
        if (newHandle == null)
        {
            message += "<br>Current Job is not found";
 
        }
        else
        {
            var runningJob = Sitecore.Jobs.JobManager.GetJob(newHandle);
            if (runningJob != null)
            {
                message += "<br>Current Job is :" + runningJob.Name;
                runningJob.QueueTime = runningJob.QueueTime.AddMinutes(-2);
                // Changing the priority of the job does not help. Sitecore picks up the jobs based on the Queue time.
 
            }
            else
            {
            message += "<br>Current Job is not found";
 
            }
        }
        ltlMessage.Text = message;
 
        return "";// runningJob.Options.Priority.ToString();
    }



    protected void ShowRefreshStatus(StringBuilder stringBuilder)
    {
        int result;
        int.TryParse(this.Request.QueryString["refresh"], out result);
        stringBuilder.Append(string.Format("Last updated: {0}. ", (object)DateTime.Now.ToString((IFormatProvider)CultureInfo.InvariantCulture)));
        int[] numArray = new int[7] { 1, 2, 5, 10, 20, 30, 60 };
        stringBuilder.Append(string.Format("<br />Refresh each <a href='jobsView.aspx' class='refresh-link {0}'>No Refresh</a>", result == 0 ? (object)"refresh-selected" : (object)string.Empty));
        foreach (int num in numArray)
        {
            string str1 = result == num ? "refresh-selected" : string.Empty;
            string str2 = string.Format(", <a href='jobsView.aspx?refresh={0}' class='refresh-link {1}'>{0} sec</a>", (object)num, (object)str1);
            stringBuilder.Append(str2);
        }
        stringBuilder.Append("<br /><br />");
    }
</script>
