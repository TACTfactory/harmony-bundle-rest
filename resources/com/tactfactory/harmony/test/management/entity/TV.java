package com.tactfactory.harmony.test.management.entity;

import com.tactfactory.harmony.annotation.Column;
import com.tactfactory.harmony.annotation.Entity;
import com.tactfactory.harmony.bundles.rest.annotation.Rest;

@Entity
@Rest
public class TV extends Furniture {

	@Column
	private String brand;
	
	@Column
	private int width;
	
	@Column
	private int height;
}
