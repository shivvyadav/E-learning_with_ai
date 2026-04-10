import {StrictMode} from "react";
import {createRoot} from "react-dom/client";
import "./index.css";
import Router from "./Router.jsx";
import {AdminProvider} from "./context/AdminContext.jsx";

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <AdminProvider>
      <Router />
    </AdminProvider>
  </StrictMode>,
);
