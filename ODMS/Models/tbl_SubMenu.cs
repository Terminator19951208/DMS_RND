//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace ODMS.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class tbl_SubMenu
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public tbl_SubMenu()
        {
            this.tbl_SubMenuSecond = new HashSet<tbl_SubMenuSecond>();
        }
    
        public int Id { get; set; }
        public string SubMenuName { get; set; }
        public string Controller { get; set; }
        public string Action { get; set; }
        public Nullable<int> MainMenuId { get; set; }
        public Nullable<int> sl { get; set; }
    
        public virtual tbl_MainMenu tbl_MainMenu { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<tbl_SubMenuSecond> tbl_SubMenuSecond { get; set; }
    }
}
