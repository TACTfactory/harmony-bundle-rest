package com.tactfactory.harmony.test.management.entity;

import java.util.ArrayList;

import com.tactfactory.harmony.annotation.Column;
import com.tactfactory.harmony.annotation.Entity;
import com.tactfactory.harmony.annotation.GeneratedValue;
import com.tactfactory.harmony.annotation.GeneratedValue.Strategy;
import com.tactfactory.harmony.annotation.Id;
import com.tactfactory.harmony.annotation.ManyToMany;
import com.tactfactory.harmony.bundles.rest.annotation.Rest;

@Entity
@Rest
public class Address {

	@Id
	@GeneratedValue(strategy=Strategy.MODE_IDENTITY)
	private int id;
	
	@Column
	private String street;
	
	@Column
	private String city;
	
	@Column
	private String country;
	
	@Column(nullable=true)
	private Integer streetNumber;
	
	@Column
	private String zipcode;
	
	@ManyToMany(inversedBy="addresses", mappedBy="addresses")
	private ArrayList<Person> inhabitants;
}
