export OHPConfiguration

function OHPConfiguration(configure_type::String,power::Real,Tc::Real,Δx::Real;hc::Real=2300.0,hc2ratio=1/30)

    xx0 = 2.45inches # some BS number Deepak had in there.
    xhinc = 0.25inches # the width of a single heater (they are 0.5in x 2in)
    horiz_trans = 0.075-1inches-5e-3; #heaters land 5mm from edge on 150mm ohp width
    ltrans_cond = (-75+20+1)*1e-3; # based on 150mm ohp width, 40mm condenser width, 1mm border.

    if configure_type == "Heater_1"
        total_heater_area = 0.5inches*2.0inches;
        qe = power/total_heater_area;



        eb3 = Rectangle(0.25inches,1.0inches,1.5*Δx)
        Tfe = RigidTransform((xx0,-0.0),0.0)
        Tfe(eb3)

        cb1 = Rectangle(0.04/2,0.0605*0.95/2 ,1.5*Δx)  
        Tfc = RigidTransform((ltrans_cond,-0.0),0.0)
        Tfc(cb1)

        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        eparams3 = PrescribedHeatFluxRegion(qe,eb3);

    return [eparams3], [cparams1]
    end

     if configure_type == "Heater_2"
        total_heater_area = 2*0.5inches*2.0inches;
        qe = power/total_heater_area;



        eb3 = Rectangle(0.5inches,1.0inches,1.5*Δx)
        Tfe = RigidTransform((xx0-xhinc,-0.0),0.0)
        Tfe(eb3)

        cb1 = Rectangle(0.04/2,0.0605*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((ltrans_cond,-0.0),0.0)
        Tfc(cb1)

        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        eparams3 = PrescribedHeatFluxRegion(qe,eb3);

    return [eparams3], [cparams1]
    end
    
    if configure_type == "Heater_3"
        total_heater_area = 3*0.5inches*2.0inches;
        qe = power/total_heater_area;



        eb3 = Rectangle(0.75inches,1.0inches,1.5*Δx)
        Tfe = RigidTransform((xx0-2*xhinc,-0.0),0.0)
        Tfe(eb3)

        cb1 = Rectangle(0.04/2,0.0605*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((ltrans_cond,-0.0),0.0)
        Tfc(cb1)

        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        eparams3 = PrescribedHeatFluxRegion(qe,eb3);

    return [eparams3], [cparams1]
    end

    if configure_type == "Heater_4"
        total_heater_area = 4*2.0inches*0.5inches;
        qe = power/total_heater_area;



        eb3 = Rectangle(1.00inches,1.0inches,1.5*Δx)
        Tfe = RigidTransform((xx0-3*xhinc,-0.0),0.0)
        Tfe(eb3)

        cb1 = Rectangle(0.04/2,0.0605*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((ltrans_cond,-0.0),0.0)
        Tfc(cb1)

        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        eparams3 = PrescribedHeatFluxRegion(qe,eb3);

    return [eparams3], [cparams1]
    end


     if configure_type == "Heater_5"
        total_heater_area = 5*2.5inches*0.5inches;
        qe = power/total_heater_area;



        eb3 = Rectangle(1.25inches,1.0inches,1.5*Δx)
        Tfe = RigidTransform((xx0-4*xhinc,-0.0),0.0)
        Tfe(eb3)

        cb1 = Rectangle(0.04/2,0.0605*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((ltrans_cond,-0.0),0.0)
        Tfc(cb1)

        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        eparams3 = PrescribedHeatFluxRegion(qe,eb3);

    return [eparams3], [cparams1]
    end


    if configure_type == "Heater_1c"
        total_heater_area = 2.0inches*0.5inches;
        qe = power/total_heater_area;

        
        eb1 = Rectangle(1.0inches,0.25inches,1.5*Δx)
        Tfe = RigidTransform((horiz_trans,-0.0),0.0)
        Tfe(eb1)

      

        cb1 = Rectangle(0.04/2,0.0605*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((ltrans_cond,-0.0),0.0)
        Tfc(cb1)

        

        eparams1 = PrescribedHeatFluxRegion(qe,eb1);
        
        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        
    return [eparams1], [cparams1]
    end


     if configure_type == "Heater_3c"
        total_heater_area = 3*2.0inches*0.5inches;
        qe = power/total_heater_area;

        eb1 = Rectangle(1.0inches,3*0.25inches,1.5*Δx)
        Tfe = RigidTransform((horiz_trans,-0.0),0.0)
        Tfe(eb1)

      

        cb1 = Rectangle(0.04/2,0.0605*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((ltrans_cond,-0.0),0.0)
        Tfc(cb1)

        

        eparams1 = PrescribedHeatFluxRegion(qe,eb1);
        
        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        
    return [eparams1], [cparams1]
    end

     if configure_type == "Heater_5c"
        # total_heater_area = 5*2.0inches*0.5inches; # exceeds Deepaks cell width
        total_heater_area = 0.0605*0.95*2.0inches; # does not exceed width 0.0605 for Deepak cell
        qe = power/total_heater_area;

        eb1 = Rectangle(1.0inches,0.0605*0.95/2,1.5*Δx)
        Tfe = RigidTransform((horiz_trans,-0.0),0.0)
        Tfe(eb1)

      

        cb1 = Rectangle(0.04/2,0.0605*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((ltrans_cond,-0.0),0.0)
        Tfc(cb1)

        

        eparams1 = PrescribedHeatFluxRegion(qe,eb1);
        
        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        
    return [eparams1], [cparams1]
    end

    if configure_type == "Heater_1e"
        total_heater_area = 2.0inches*0.50inches;
        qe = power/total_heater_area;

        eb1 = Rectangle(1.0inches,0.25inches,1.5*Δx)
        Tfe = RigidTransform((horiz_trans,1inches-0.003),0.0) #keep it from going over edge
        Tfe(eb1)

       

        cb1 = Rectangle(0.04/2,0.0605*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((ltrans_cond,-0.0),0.0)
        Tfc(cb1)

        

        eparams1 = PrescribedHeatFluxRegion(qe,eb1);
        
        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        
    return [eparams1], [cparams1]
    end




    if configure_type == "Heater_2e"
        total_heater_area = 2*2.0inches*0.50inches;
        qe = power/total_heater_area;

        eb1 = Rectangle(1.0inches,0.25inches,1.5*Δx)
        Tfe = RigidTransform((horiz_trans,1.0inches-0.003),0.0) #keep it from going over edge
        Tfe(eb1)

        eb2 = Rectangle(1.0inches,0.25inches,1.5*Δx)
        Tfe = RigidTransform((horiz_trans,-1.0inches+0.003),0.0) #keep it from going over edge
        Tfe(eb2)

        cb1 = Rectangle(0.04/2,0.0605*0.95/2 ,1.5*Δx) 
        Tfc = RigidTransform((ltrans_cond,-0.0),0.0)
        Tfc(cb1)

        

        eparams1 = PrescribedHeatFluxRegion(qe,eb1);
        eparams2 = PrescribedHeatFluxRegion(qe,eb2);
        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        
    return [eparams1,eparams2], [cparams1]
    end


     if configure_type == "Heater_2a"
        total_heater_area = 2.0inches*0.50inches;
        qe = power/total_heater_area;

        eb1 = Rectangle(1.0inches,0.25inches,1.5*Δx)
        Tfe = RigidTransform((horiz_trans,0.5inches),0.0)
        Tfe(eb1)

        eb2 = Rectangle(1.0inches,0.25inches,1.5*Δx)
        Tfe = RigidTransform((horiz_trans,-0.5inches),0.0)
        Tfe(eb2)

        cb1 = Rectangle(0.04/2,0.0605*0.95/2 ,1.5*Δx) 
        Tfc = RigidTransform((ltrans_cond,-0.0),0.0)
        Tfc(cb1)

        

        eparams1 = PrescribedHeatFluxRegion(qe,eb1);
        eparams2 = PrescribedHeatFluxRegion(qe,eb2);
        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        
    return [eparams1,eparams2], [cparams1]
    end

if configure_type == "ASETS-II OHP 1 LARGE HEATER"
        total_heater_area = 2.0inches*2.0inches;
        qe = power/total_heater_area;

        eb1 = Rectangle(0.5inches,1.0inches,1.5*Δx)
        Tfe = RigidTransform((0.7inches,-0.0),0.0)
        Tfe(eb1)

        eb2 = Rectangle(0.5inches,1.0inches,1.5*Δx)
        Tfe = RigidTransform((-0.7inches,-0.0),0.0)
        Tfe(eb2)

        cb1 = Rectangle(0.5inches,0.0648*0.95/2 ,1.5*Δx) # 0.02916 = 0.0648*0.9/2 
        Tfc = RigidTransform((-2.45inches,-0.0),0.0)
        Tfc(cb1)

        cb2 = Rectangle(0.5inches,0.0648*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((2.45inches,-0.0),0.0)
        Tfc(cb2)

        eparams1 = PrescribedHeatFluxRegion(qe,eb1);
        eparams2 = PrescribedHeatFluxRegion(qe,eb2);
        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        cparams2 = PrescribedHeatModelRegion(hc,Tc,cb2);

    return [eparams1,eparams2], [cparams1,cparams2]
    end





    # In one sided condenser case, the "adiabatic" side is not completely adiabatic in the code. 
    # Instead it is a fraction "hc2ratio" of the regular condenser htc. 
    # And it is a tunable parameter for now as it is a representaion of the insulation material:)

    if (configure_type == "Modified ASETS-II OHP 2 HEATER") || (configure_type == "Modified ASETS-II OHP 1 HEATER")
        total_heater_area = 2.0inches*0.5inches;
        qe = power/total_heater_area;

        eb1 = Rectangle(0.5inches,1.0inches,1.5*Δx)
        Tfe = RigidTransform((0.7inches,-0.0),0.0)
        Tfe(eb1)

        eb2 = Rectangle(0.5inches,1.0inches,1.5*Δx)
        Tfe = RigidTransform((-0.7inches,-0.0),0.0)
        Tfe(eb2)

        cb1 = Rectangle(0.5inches,0.0648*0.95/2 ,1.5*Δx) # 0.02916 = 0.0648*0.9/2 
        Tfc = RigidTransform((-2.45inches,-0.0),0.0)
        Tfc(cb1)

        cb2 = Rectangle(0.5inches,0.0648*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((2.45inches,-0.0),0.0)
        Tfc(cb2)

        # cb3 = Rectangle(1.9inches,1.2inches ,1.5*Δx)
        # Tfc = RigidTransform((0.0,-0.0),0.0)
        # Tfc(cb3)

        eparams1 = PrescribedHeatFluxRegion(qe,eb1);
        eparams2 = PrescribedHeatFluxRegion(qe,eb2);
        cparams1 = PrescribedHeatModelRegion(hc*hc2ratio,Tc,cb1);
        cparams2 = PrescribedHeatModelRegion(hc,Tc,cb2);
        # cparams3 = PrescribedHeatModelRegion(10.0,Tc,cb3);

    return [eparams1,eparams2], [cparams1,cparams2]
    end

    if configure_type == "ASETS-II OHP 1 SMALL HEATER"
        total_heater_area = 0.5inches*0.5inches;
        qe = power/total_heater_area;

        eb1 = Rectangle(0.25inches,0.25inches,1.5*Δx)
        Tfe = RigidTransform((0.0inches,-0.0),0.0)
        Tfe(eb1)

        cb1 = Rectangle(0.5inches,0.0648*0.95/2 ,1.5*Δx) # 0.02916 = 0.0648*0.9/2 
        Tfc = RigidTransform((-2.45inches,-0.0),0.0)
        Tfc(cb1)

        cb2 = Rectangle(0.5inches,0.0648*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((2.45inches,-0.0),0.0)
        Tfc(cb2)

        eparams1 = PrescribedHeatFluxRegion(qe,eb1);
        cparams1 = PrescribedHeatModelRegion(hc,Tc,cb1);
        cparams2 = PrescribedHeatModelRegion(hc,Tc,cb2);

    return [eparams1], [cparams1,cparams2]
    end

    if (configure_type == "ASETS-II OHP 2 SMALL HEATER") || (configure_type == "ASETS-II OHP 3 SMALL HEATER")
        total_heater_area = 0.5inches*0.5inches;
        qe = power/total_heater_area;

        eb1 = Rectangle(0.25inches,0.25inches,1.5*Δx)
        Tfe = RigidTransform((0.0inches,-0.0),0.0)
        Tfe(eb1)

        cb1 = Rectangle(0.5inches,0.0648*0.95/2 ,1.5*Δx) # 0.02916 = 0.0648*0.9/2 
        Tfc = RigidTransform((-2.45inches,-0.0),0.0)
        Tfc(cb1)

        cb2 = Rectangle(0.5inches,0.0648*0.95/2 ,1.5*Δx)
        Tfc = RigidTransform((2.45inches,-0.0),0.0)
        Tfc(cb2)

        eparams1 = PrescribedHeatFluxRegion(qe,eb1);
        cparams1 = PrescribedHeatModelRegion(hc*hc2ratio,Tc,cb1);
        cparams2 = PrescribedHeatModelRegion(hc,Tc,cb2);

    return [eparams1], [cparams1,cparams2]
    end


    return "configuration not recognized"
end

