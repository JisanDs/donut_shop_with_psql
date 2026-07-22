import streamlit as st


# setup for pages
user_guide = st.Page(
    page="./pages/user_guide_page.py",
    title="User Guide"
)

sale_revenue = st.Page(
    page="./pages/sales_revenue_page.py",
    title="Sale & Revenue"
)

inv_manage = st.Page(
    page="./pages/inv_manage_waste_page.py",
    title="Inventory"
)

hr_status = st.Page(
    page="./pages/hr_status_page.py",
    title="Employees Status"
)


# setup navigation side bar
pages = st.navigation([user_guide, sale_revenue, inv_manage, hr_status])

# run dashboard
pages.run()
