﻿using System.Web.Mvc;
using System.Web.Routing;

namespace ODMS
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
            );
            
            routes.MapRoute(
                name: "Buyer",
                url: "{controller}/{action}/{id}/{startdate}/{enddate}/skuid",
                defaults: new { controller = "ReportDelivery", action = "Index", id = UrlParameter.Optional, startdate = UrlParameter.Optional, enddate = UrlParameter.Optional, skuid = UrlParameter.Optional }
            );



        }
    }
}
